# frozen_string_literal: true

module Applitools
  class RenderingInfo
    attr_accessor :response
    def initialize(response)
      Applitools::ArgumentGuard.not_nil(response, 'response')
      Applitools::ArgumentGuard.hash(response, 'response')
      self.response = response
    end

    def service_url
      response['serviceUrl']
    end

    def results_url
      response['resultsUrl']
    end

    def stitching_service_url
      response['stitchingServiceUrl']
    end

    def access_token
      response['accessToken']
    end
  end
end
