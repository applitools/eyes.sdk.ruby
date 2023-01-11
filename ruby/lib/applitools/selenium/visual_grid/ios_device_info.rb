require_relative 'ios_device_name'

module Applitools
  module Selenium
    class IosDeviceInfo < IRenderBrowserInfo
      DEFAULT_CONFIG = proc do
        {
            platform: 'ios',
            browser_type: BrowserType::IOS_SAFARI,
            # size_mode: 'full-page',
            viewport_size: Applitools::RectangleSize.from_any_argument(width: 0, height: 0)
        }
      end

      object_field :ios_device_info, Applitools::Selenium::EmulationBaseInfo

      class << self
        def default_config
          DEFAULT_CONFIG.call
        end
      end

      def initialize(options = {})
        super
        self.ios_device_info = EmulationInfo.new.tap do |ei|
          ei.device_name = options[:device_name]
          ei.screen_orientation = options[:screen_orientation] || options[:orientation] || Orientation::PORTRAIT
        end
      end

      def to_s
        "#{ios_device_info.device_name} - #{ios_device_info.screen_orientation}"
      end

      def device_name
        ios_device_info.device_name
      end

      def to_hash
        {iosDeviceInfo: ios_device_info.to_hash}
      end

      private

      class EmulationInfo < EmulationBaseInfo
        enum_field :device_name, IosDeviceName.enum_values
        enum_field :screen_orientation, Orientation.enum_values

        def json_data
          {
              name: device_name,
              screenOrientation: screen_orientation,
              version: 'latest'
          }
        end

        def to_hash
          {
            deviceName: device_name,
            screenOrientation: screen_orientation,
            iosVersion: 'latest'
          }
        end
      end
    end
  end
end