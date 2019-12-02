# frozen_string_literal: true
require 'applitools/selenium/browser_types'

module Applitools
  module Selenium
    class RenderBrowserInfo < ::Applitools::AbstractConfiguration
      DEFAULT_CONFIG = proc do
        {
          platform: 'linux',
          browser_type: BrowserTypes::CHROME,
          # size_mode: 'full-page',
          viewport_size: Applitools::RectangleSize.from_any_argument(width: 0, height: 0)
        }
      end
      class << self
        def default_config
          DEFAULT_CONFIG.call
        end
      end

      object_field :viewport_size, Applitools::RectangleSize
      enum_field :browser_type, BrowserTypes.enum_values
      string_field :platform
      string_field :size_mode
      string_field :baseline_env_name
      object_field :emulation_info, Applitools::Selenium::EmulationBaseInfo

      def platform
        case browser_type
        when BrowserTypes::EDGE
          'windows'
        else
          'linux'
        end
      end

      def to_s
        return "#{viewport_size} (#{browser_type})" unless emulation_info
        "#{emulation_info.device_name} - #{emulation_info.screen_orientation}"
      end
    end
  end
end
