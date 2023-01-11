# frozen_string_literal: true
require_relative 'emulation_base_info'
require_relative 'i_render_browser_info'
module Applitools
  module Selenium
    class ChromeEmulationInfo < IRenderBrowserInfo
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

      object_field :emulation_info, Applitools::Selenium::EmulationBaseInfo

      # def device_name
      #   emulation_info.device_name
      # end
      #
      def initialize(*args)
        options = Applitools::Utils.extract_options!(args.dup)
        super(options)
        case args[0]
        when String
          self.emulation_info = EmulationInfo.new.tap do |ei|
            ei.device_name = args[0]
            ei.screen_orientation = args[1] || Orientation::PORTRAIT
          end
        when Hash
          self.emulation_info = EmulationInfo.new.tap do |ei|
            ei.device_name = args[0][:device_name]
            ei.screen_orientation = args[0][:screen_orientation] || Orientation::PORTRAIT
          end
        else
          raise Applitools::EyesIllegalArgument, 'You should pass :device_name and :screen_orientation'
        end
      end

      def to_s
        "#{emulation_info.device_name} - #{emulation_info.screen_orientation}"
      end

      def device_name
        emulation_info.device_name + ' (chrome emulation)'
      end

      def to_hash
        {chromeEmulationInfo: emulation_info.json_data}
      end


      private

      class EmulationInfo < Applitools::Selenium::EmulationBaseInfo
        enum_field :device_name, Devices.enum_values
        enum_field :screen_orientation, Orientations.enum_values

        def json_data
          {
              :'deviceName' => device_name,
              :'screenOrientation' => screen_orientation
          }
        end
      end
    end
  end
end
