# frozen_string_literal: true
require 'applitools/selenium/browser_types'

module Applitools
  module Selenium
    class DesktopBrowserInfo < IRenderBrowserInfo
      DEFAULT_CONFIG = proc do
        {
            platform: 'linux',
            browser_type: BrowserType::CHROME,
            # size_mode: 'full-page',
            viewport_size: Applitools::RectangleSize.from_any_argument(width: 0, height: 0)
        }
      end

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
        case browser_type
        when BrowserType::EDGE_LEGACY, BrowserType::EDGE_CHROMIUM, BrowserType::EDGE_CHROMIUM_ONE_VERSION_BACK
          'windows'
        else
          'linux'
        end
      end

      def device_name
        'desktop'
      end

      def to_hash
        result = viewport_size.to_h
        result[:name] = browser_type unless browser_type.nil?
        result
      end

    end
  end
end
