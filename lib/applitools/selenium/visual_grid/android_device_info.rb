require_relative 'i_render_browser_info'
require_relative 'emulation_base_info'

module Applitools
  module Selenium
    class AndroidDeviceInfo < IRenderBrowserInfo
      DEFAULT_CONFIG = proc do
        {
          viewport_size: Applitools::RectangleSize.from_any_argument(width: 0, height: 0)
        }
      end

      object_field :android_device_info, Applitools::Selenium::EmulationBaseInfo

      class << self
        def default_config
          DEFAULT_CONFIG.call
        end
      end

      def initialize(options = {})
        super
        self.android_device_info = EmulationInfo.new.tap do |ei|
          ei.device_name = options[:device_name]
          ei.screen_orientation = options[:screen_orientation] || options[:orientation] || Orientation::PORTRAIT
        end
      end

      def to_s
        "#{android_device_info.device_name} - #{android_device_info.screen_orientation}"
      end

      def device_name
        android_device_info.device_name
      end

      def to_hash
        {androidDeviceInfo: android_device_info.to_hash}
      end

      private

      class EmulationInfo < EmulationBaseInfo
        enum_field :device_name, Devices.enum_values
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