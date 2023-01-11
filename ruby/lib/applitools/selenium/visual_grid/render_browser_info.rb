# frozen_string_literal: true
require 'applitools/selenium/browser_types'
# We should not break the API
module Applitools
  module Selenium
    class RenderBrowserInfo < IRenderBrowserInfo
      DEFAULT_CONFIG = proc do
        {
            platform: 'linux',
            browser_type: BrowserTypes::CHROME,
            # size_mode: 'full-page',
            viewport_size: Applitools::RectangleSize.from_any_argument(width: 0, height: 0)
        }
      end

      object_field :ios_device_info, Applitools::Selenium::EmulationBaseInfo
      object_field :emulation_info, Applitools::Selenium::EmulationBaseInfo

      class << self
        def default_config
          DEFAULT_CONFIG.call
        end
      end

      def initialize(options = {})
        super
        if options[:width] && options[:height]
          self.viewport_size = Applitools::RectangleSize.from_any_argument(width: options[:width], height: options[:height])
        end
        self.browser_type = options[:browser_type] if options[:browser_type]
      end

      def platform
        return 'ios' if ios_device_info
        case browser_type
        when BrowserType::EDGE_LEGACY, BrowserType::EDGE_CHROMIUM, BrowserType::EDGE_CHROMIUM_ONE_VERSION_BACK
          'windows'
        else
          'linux'
        end
      end

      def to_s
        if emulation_info
          "#{emulation_info.device_name} - #{emulation_info.screen_orientation}"
        elsif ios_device_info
          "#{ios_device_info.device_name} - #{ios_device_info.screen_orientation}"
        end
        "#{viewport_size} (#{browser_type})"
      end

      def device_name
        if ios_device_info
          return ios_device_info.device_name
        elsif emulation_info
          return emulation_info.device_name + ' (chrome emulation)'
        end
        'desktop'
      end
    end
  end
end
