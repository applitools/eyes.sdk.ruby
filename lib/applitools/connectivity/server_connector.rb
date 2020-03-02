# frozen_string_literal: false

require 'faraday'
require 'oj'
require 'securerandom'

Oj.default_options = { :mode => :compat }

require 'uri'

module Applitools::Connectivity
  class ServerConnector
    class ScreenshotUploadError < Applitools::EyesError; end
    extend Applitools::Helpers
    DEFAULT_SERVER_URL = 'https://eyesapi.applitools.com'.freeze

    SSL_CERT = File.join(File.dirname(File.expand_path(__FILE__)), '../../../certs/cacert.pem').to_s.freeze
    DEFAULT_TIMEOUT = 300
    API_SESSIONS = '/api/sessions'.freeze
    API_SESSIONS_RUNNING = API_SESSIONS + '/running/'.freeze
    API_SINGLE_TEST = API_SESSIONS + '/'.freeze

    RENDER_INFO_PATH = API_SESSIONS + '/renderinfo'.freeze
    RENDER = '/render'.freeze

    RESOURCES_SHA_256 = '/resources/sha256/'.freeze
    RENDER_STATUS = '/render-status'.freeze
    CLOSE_BATCH = '/api/sessions/batches/%s/close/bypointerid'.freeze

    HTTP_STATUS_CODES = {
      created: 201,
      accepted: 202,
      ok: 200,
      gone: 410
    }.freeze

    attr_accessor :server_url
    attr_reader :endpoint_url
    attr_reader :proxy
    environment_attribute :api_key, 'APPLITOOLS_API_KEY'

    def initialize(url = nil)
      self.server_url = url
    end

    def rendering_info
      response = long_get(URI.join(server_url, RENDER_INFO_PATH), content_type: 'application/json')
      unless response.status == HTTP_STATUS_CODES[:ok]
        raise Applitools::EyesError, "Error getting render info (#{response.status}})"
      end
      Oj.load response.body
    end

    def render(service_url, access_key, requests)
      uri = URI.join(URI(service_url), RENDER)
      response = dummy_post(
        uri,
        body: requests.json,
        headers: {
          'X-Auth-Token' => access_key
        },
        timeout: 10
      )
      unless response.status == HTTP_STATUS_CODES[:ok]
        raise Applitools::EyesError, "Error render processing (#{response.status}, #{response.body})"
      end
      Oj.load response.body
    end

    def put_screenshot(rendering_info, screenshot)
      uuid = SecureRandom.uuid
      upload_path = URI.parse(rendering_info.results_url.gsub(/__random__/, uuid))
      retry_count = 3
      wait = 0.5
      loop do
        raise ScreenshotUploadError, "Error uploading screenshot (#{upload_path})" if retry_count <= 0
        Applitools::EyesLogger.info("Trying to upload screenshot (#{upload_path})...")
        begin
          response = dummy_put(
            upload_path,
            body: screenshot.image.to_blob,
            headers: {
              'x-ms-blob-type': 'BlockBlob',
              'X-Auth-Token': rendering_info.access_token
            },
            query: URI.decode_www_form(upload_path.query).to_h,
            content_type: 'image/png'
          )
          break if response.status == HTTP_STATUS_CODES[:created]
          Applitools::EyesLogger.info("Failed. Retrying in #{wait} seconds")
          sleep(wait)
        rescue StandardError => e
          Applitools::EyesLogger.error(e.class.to_s)
          Applitools::EyesLogger.error(e.message)
          Applitools::EyesLogger.info("Failed. Retrying in #{wait} seconds")
          sleep(wait)
        ensure
          retry_count -= 1
          wait *= 2
        end
      end
      Applitools::EyesLogger.info('Done.')
      upload_path.to_s
    end

    def render_put_resource(service_url, access_key, resource, render)
      uri = URI(service_url)
      uri.path = RESOURCES_SHA_256 + resource.hash
      Applitools::EyesLogger.debug("PUT resource: (#{resource.url}) - #{uri}")
      # Applitools::EyesLogger.debug("Resource content: #{resource.content}")
      response = dummy_put(
        uri,
        body: resource.content,
        content_type: resource.content_type,
        headers: {
          'X-Auth-Token' => access_key
        },
        query: { 'render-id' => render['renderId'] }
      )
      unless response.status == HTTP_STATUS_CODES[:ok]
        raise Applitools::EyesError, "Error putting resource: #{response.status}, #{response.body}"
      end
      resource.hash
    end

    def render_status_by_id(service_url, access_key, running_renders_json)
      uri = URI(service_url)
      uri.path = RENDER_STATUS
      response = dummy_post(
        uri,
        body: running_renders_json,
        content_type: 'application/json',
        headers: {
          'X-Auth-Token' => access_key
        },
        timeout: 2
      )
      unless response.status == HTTP_STATUS_CODES[:ok]
        raise Applitools::EyesError, "Error getting server status, #{response.status} #{response.body}"
      end

      Oj.load(response.body)
    end

    def download_resource(url, ua_string = nil)
      Applitools::EyesLogger.debug "Fetching #{url}..."
      resp_proc = proc do |u|
        Faraday::Connection.new(
          u,
          ssl: { ca_file: SSL_CERT },
          proxy: @proxy.nil? ? nil : @proxy.to_hash
        ).send(:get) do |req|
          req.options.timeout = DEFAULT_TIMEOUT
          req.headers['Accept-Encoding'] = 'identity'
          req.headers['User-Agent'] = ua_string if ua_string
        end
      end
      response = resp_proc.call(url)
      redirect_count = 10
      while response.status == 301 && redirect_count > 0
        redirect_count -= 1
        response = resp_proc.call(response.headers['location'])
      end
      Applitools::EyesLogger.debug 'Done!'
      response
    end

    def close_batch(batch_id)
      if 'true'.casecmp(ENV['APPLITOOLS_DONT_CLOSE_BATCHES'] || '') == 0
        return Applitools::EyesLogger.info(
          'APPLITOOLS_DONT_CLOSE_BATCHES environment variable set to true. Doing nothing.'
        ) && false
      end
      Applitools::ArgumentGuard.not_nil(batch_id, 'batch_id')
      Applitools::EyesLogger.info("Called with #{batch_id}")
      url = CLOSE_BATCH % batch_id
      response = delete(URI.join(endpoint_url, url))
      Applitools::EyesLogger.info "delete batch is done with #{response.status} status"
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
      body = if data.screenshot.empty?
               content_type = 'application/json'
               json_data
             else
               content_type = 'application/octet-stream'
               [json_data.length].pack('L>') + json_data + data.screenshot
             end

      Applitools::EyesLogger.debug 'Sending match data...'
      Applitools::EyesLogger.debug json_data
      res = long_post(URI.join(endpoint_url, session.id.to_s), content_type: content_type, body: body)
      raise Applitools::EyesError.new("Request failed: #{res.status} #{res.headers}") unless res.success?
      # puts Oj.load(res.body)
      Applitools::MatchResult.new Oj.load(res.body)
    end

    RETRY_DELAY = 0.5
    RETRY_STEP_FACTOR = 1.5
    RETRY_MAX_DELAY = 5

    def match_single_window_data(data)
      # Notice that this does not include the screenshot.
      json_data = Oj.dump(data.to_hash).force_encoding('BINARY')
      body = [json_data.length].pack('L>') + json_data + data.screenshot
      # Applitools::EyesLogger.debug json_data
      begin
        Applitools::EyesLogger.debug 'Sending match data...'
        res = long_post(
          @single_check_endpoint_url,
          content_type: 'application/octet-stream',
          body: body,
          query: { agent_id: data.agent_id }
        )
      rescue Errno::EWOULDBLOCK, Faraday::ConnectionFailed
        @delays ||= request_delay(RETRY_DELAY, RETRY_STEP_FACTOR, RETRY_MAX_DELAY)
        begin
          sleep @delays.next
        rescue StopIteration
          raise Applitools::UnknownNetworkStackError.new('Unknown network stack error')
        end
        res = match_single_window_data(data)
      ensure
        @delays = nil
      end
      raise Applitools::EyesError.new("Request failed: #{res.status} #{res.headers} #{res.body}") unless res.success?
      res
    end

    def match_single_window(data)
      res = match_single_window_data(data)
      Applitools::TestResults.new Oj.load(res.body)
    end

    def start_session(session_start_info)
      request_body = Oj.dump(
        startInfo: Applitools::Utils.camelcase_hash_keys(session_start_info.to_hash)
      )
      res = long_post(
        endpoint_url, body: request_body
      )
      raise Applitools::EyesError.new("Request failed: #{res.status} #{res.body} #{request_body}") unless res.success?

      response = Oj.load(res.body)
      Applitools::Session.new(response['id'], response['url'], res.status == HTTP_STATUS_CODES[:created])
    end

    def stop_session(session, aborted = nil, save = false)
      res = long_delete(URI.join(endpoint_url, session.id.to_s), query: { aborted: aborted, updateBaseline: save })
      raise Applitools::EyesError.new("Request failed: #{res.status}") unless res.success?

      response = Oj.load(res.body)
      Applitools::TestResults.new(response)
    end

    def post_dom_json(dom_data)
      Applitools::EyesLogger.debug 'About to send captured DOM...'
      # request_body = Oj.dump(dom_data)
      request_body = dom_data
      Applitools::EyesLogger.debug request_body
      processed_request_body = yield(request_body) if block_given?
      res = post(
        endpoint_url + 'data',
        body: processed_request_body.nil? ? request_body : processed_request_body,
        content_type: 'application/octet-stream'
      )

      Applitools::EyesLogger.debug 'Done!'
      raise Applitools::EyesError.new("Request failed: #{res.status} #{res.body}") unless res.success?
      Applitools::EyesLogger.debug  'Server response headers:'
      Applitools::EyesLogger.debug  res.headers.inspect
      res.headers['location']
    end

    private

    DEFAULT_HEADERS = {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }.freeze

    LONG_REQUEST_DELAY = 2 # seconds
    MAX_LONG_REQUEST_DELAY = 10 # seconds
    LONG_REQUEST_DELAY_MULTIPLICATIVE_INCREASE_FACTOR = 1.5

    [:get, :post, :delete, :put].each do |method|
      define_method method do |url, options = {}|
        request(url, method, options)
      end

      define_method "dummy_#{method}" do |url, options = {}|
        dummy_request(url, method, options)
      end

      define_method "long_#{method}" do |url, options = {}, request_delay = LONG_REQUEST_DELAY|
        long_request(url, method, request_delay, options)
      end

      private method, "long_#{method}"
    end

    def request_delay(first_delay, step_factor, max_delay)
      Enumerator.new do |y|
        delay = first_delay
        loop do
          y << delay
          delay *= step_factor
          break if delay > max_delay
        end
      end
    end

    def request(url, method, options = {})
      Applitools::EyesLogger.debug("Requesting #{url} (method: #{method})")
      response = Faraday::Connection.new(
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
      Applitools::EyesLogger.debug("Got a response: #{response.status} #{response.reason_phrase}")
      response
    end

    def dummy_request(url, method, options = {})
      Faraday::Connection.new(
        url,
        ssl: { ca_file: SSL_CERT },
        proxy: @proxy.nil? ? nil : @proxy.to_hash
      ).send(method) do |req|
        req.options.timeout = options[:timeout] || DEFAULT_TIMEOUT
        req.headers = DEFAULT_HEADERS.merge(options[:headers] || {})
        req.headers['Content-Type'] = options[:content_type] if options.key?(:content_type)
        req.params = options[:query] || {}
        req.body = options[:body]
      end
    end

    def long_request(url, method, request_delay, options = {})
      delay = request_delay
      options = { headers: {
        'Eyes-Expect' => '202+location'
      }.merge(eyes_date_header) }.merge! options
      res = request(url, method, options)
      check_status(res, delay)
    end

    def eyes_date_header
      { 'Eyes-Date' => Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT') }
    end

    def check_status(res, delay)
      case res.status
      when HTTP_STATUS_CODES[:ok]
        res
      when HTTP_STATUS_CODES[:accepted]
        second_step_url = res.headers[:location]
        loop do
          delay = [MAX_LONG_REQUEST_DELAY, (delay * LONG_REQUEST_DELAY_MULTIPLICATIVE_INCREASE_FACTOR).round].min
          Applitools::EyesLogger.debug "Still running... retrying in #{delay}s"
          sleep delay
          second_step_options = {
            headers: {}.merge(eyes_date_header)
          }
          res = request(second_step_url, :get, second_step_options)
          break unless res.status == HTTP_STATUS_CODES[:ok]
        end
        check_status(res, delay)
      when HTTP_STATUS_CODES[:created]
        last_step_url = res.headers[:location]
        last_step_url.nil? ? res : request(last_step_url, :delete, headers: eyes_date_header)
      when HTTP_STATUS_CODES[:gone]
        raise Applitools::EyesError.new('The server task has gone.')
      else
        raise Applitools::EyesError.new('Unknown error processing long request')
      end
    end
  end
end
