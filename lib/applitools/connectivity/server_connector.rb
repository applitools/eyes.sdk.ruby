require 'faraday'
require 'oj'
Oj.default_options = { :mode => :compat }

require 'uri'

module Applitools::Connectivity
  class ServerConnector
    DEFAULT_SERVER_URL = 'https://eyessdk.applitools.com'.freeze

    SSL_CERT = File.join(File.dirname(File.expand_path(__FILE__)), '../../../certs/cacert.pem').to_s.freeze
    DEFAULT_TIMEOUT = 300

    API_SESSIONS_RUNNING = '/api/sessions/running/'.freeze
    API_SINGLE_TEST = '/api/sessions/'.freeze

    HTTP_STATUS_CODES = {
      created: 201,
      accepted: 202
    }.freeze

    attr_accessor :server_url, :api_key
    attr_reader :endpoint_url
    attr_reader :proxy

    def initialize(url = nil)
      self.server_url = url
    end

    def server_url=(url)
      @server_url = url.nil? ? DEFAULT_SERVER_URL : url
      unless @server_url.is_a? String
        raise Applitools::EyesIllegalArgument.new 'You should pass server url as a String!' \
          " (#{@server_url.class} is passed)"
      end
      @endpoint_url = URI.join(@server_url, API_SESSIONS_RUNNING).to_s
      @single_check_endpoint_url = URI.join(@server_url, API_SINGLE_TEST).to_s
    end

    def set_proxy(uri, user = nil, password = nil)
      self.proxy = Proxy.new uri, user, password
    end

    def proxy=(value)
      unless value.nil? || value.is_a?(Applitools::Connectivity::Proxy)
        raise Applitools::EyesIllegalArgument.new 'Expected value to be instance of Applitools::Connectivity::Proxy,' \
          ' got #{value.class}'
      end
      @proxy = value
    end

    def match_window(session, data)
      # Notice that this does not include the screenshot.
      json_data = Oj.dump(Applitools::Utils.camelcase_hash_keys(data.to_hash)).force_encoding('BINARY')
      body = [json_data.length].pack('L>') + json_data + data.screenshot
      Applitools::EyesLogger.debug 'Sending match data...'
      # Applitools::EyesLogger.debug json_data
      res = post(URI.join(endpoint_url, session.id.to_s), content_type: 'application/octet-stream', body: body)
      raise Applitools::EyesError.new("Request failed: #{res.status} #{res.headers}") unless res.success?
      Applitools::MatchResult.new Oj.load(res.body)
    end

    def match_single_window(data)
      # Notice that this does not include the screenshot.
      json_data = Oj.dump(data.to_hash).force_encoding('BINARY')
      body = [json_data.length].pack('L>') + json_data + data.screenshot
      # Applitools::EyesLogger.debug json_data
      Applitools::EyesLogger.debug 'Sending match data...'
      res = post(@single_check_endpoint_url, content_type: 'application/octet-stream', body: body)
      raise Applitools::EyesError.new("Request failed: #{res.status} #{res.headers} #{res.body}") unless res.success?
      Applitools::TestResults.new Oj.load(res.body)
    end

    def start_session(session_start_info)
      res = post(endpoint_url, body: Oj.dump(startInfo:
                                                 Applitools::Utils.camelcase_hash_keys(session_start_info.to_hash)))
      raise Applitools::EyesError.new("Request failed: #{res.status} #{res.body}") unless res.success?

      response = Oj.load(res.body)
      Applitools::Session.new(response['id'], response['url'], res.status == HTTP_STATUS_CODES[:created])
    end

    def stop_session(session, aborted = nil, save = false)
      res = long_delete(URI.join(endpoint_url, session.id.to_s), query: { aborted: aborted, updateBaseline: save })
      raise Applitools::EyesError.new("Request failed: #{res.status}") unless res.success?

      response = Oj.load(res.body)
      Applitools::TestResults.new(response)
    end

    private

    DEFAULT_HEADERS = {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }.freeze

    LONG_REQUEST_DELAY = 2 # seconds
    MAX_LONG_REQUEST_DELAY = 10 # seconds
    LONG_REQUEST_DELAY_MULTIPLICATIVE_INCREASE_FACTOR = 1.5

    [:get, :post, :delete].each do |method|
      define_method method do |url, options = {}|
        request(url, method, options)
      end

      define_method "long_#{method}" do |url, options = {}|
        long_request(url, method, options)
      end
    end

    def request(url, method, options = {})
      Faraday::Connection.new(
        url,
        ssl: { ca_file: SSL_CERT },
        proxy: @proxy.nil? ? nil : @proxy.to_hash
      ).send(method) do |req|
        req.options.timeout = DEFAULT_TIMEOUT
        req.headers = DEFAULT_HEADERS.merge(options[:headers] || {})
        req.headers['Content-Type'] = options[:content_type] if options.key?(:content_type)
        req.params = { apiKey: api_key }.merge(options[:query] || {})
        req.body = options[:body]
      end
    end

    def long_request(url, method, options = {})
      delay = LONG_REQUEST_DELAY
      (options[:headers] ||= {})['Eyes-Expect'] = '202-accepted'

      loop do
        # Date should be in RFC 1123 format.
        options[:headers]['Eyes-Date'] = Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')

        res = request(url, method, options)
        return res unless res.status == HTTP_STATUS_CODES[:accepted]

        Applitools::EyesLogger.debug "Still running... retrying in #{delay}s"
        sleep delay

        delay = [MAX_LONG_REQUEST_DELAY, (delay * LONG_REQUEST_DELAY_MULTIPLICATIVE_INCREASE_FACTOR).round].min
      end
    end
  end
end
