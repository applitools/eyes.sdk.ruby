require 'eyes_selenium'

module Applitools
  class EyesTestResult
    attr_accessor :close_output, :eyes, :proxy

    def initialize(close_output, eyes)
      raise EyesIllegalArgument, "Expected :close_output to be a Applitools::TestResults, but got #{close_output.class}" unless
          close_output.is_a? Applitools::TestResults
      raise EyesIllegalArgument, "Expected :eyes to be a Applitools::EyesBase, but got #{close_output.class}" unless
          eyes.is_a? Applitools::EyesBase

      self.close_output = close_output
      self.eyes = eyes
      self.index = 0
    end

    def actual_floating(index=0)
      result['actualAppOutput'][index]['imageMatchSettings']['floating'].map do |floating_region|
        FloatingRegion.new(
          floating_region['left'],
          floating_region['top'],
          floating_region['width'],
          floating_region['height'],
          floating_region['maxLeftOffset'],
          floating_region['maxUpOffset'],
          floating_region['maxRightOffset'],
          floating_region['maxDownOffset']
        )
      end
    end

    private

    attr_accessor :result, :index

    def result
      @result ||= Oj.load(get_result.body)
    end

    def get_result
      Faraday::Connection.new(
          result_url,
          ssl: { ca_file: Applitools::Connectivity::ServerConnector::SSL_CERT },
          proxy: @proxy.nil? ? nil : @proxy.to_hash
      ).send(:get) do |req|
        req.headers['Content-Type'] = 'application/json'
      end
    end

    def result_url
      results = close_output.original_results
      URI.parse(results['apiUrls']['session']).tap do |q|
        q.query = URI.encode_www_form([['format', 'json'], ['AccessToken', results['secretToken']], ['apiKey', eyes.api_key]])
      end
    end
  end
end
