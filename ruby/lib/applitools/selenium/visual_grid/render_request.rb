# frozen_string_literal: true

require 'oj'
module Applitools
  module Selenium
    class RenderRequest
      include Applitools::Jsonable
      json_fields :renderId, :webhook, :url, :dom, :resources, :scriptHooks,
        :selectorsToFindRegionsFor, :sendDom, :agentId

      json_fields :renderInfo, :browser, :platform, :stitchingService, :options

      def initialize(*args)
        options = Applitools::Utils.extract_options! args
        self.agent_id = "eyes.selenium.visualgrid.ruby/#{Applitools::VERSION}"
        self.script_hooks = {}
        self.selectors_to_find_regions_for = []
        options.keys.each do |k|
          send("#{k}=", options[k]) if options[k] && respond_to?("#{k}=")
        end
      end
    end
  end
end
