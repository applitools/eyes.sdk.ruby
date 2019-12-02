# frozen_string_literal: true
require 'applitools/selenium/visual_grid/emulation_base_info'
module Applitools
  module Selenium
    class ChromeEmulationInfo < EmulationBaseInfo
      attr_accessor :device_name

      def initialize(device_name, screen_orientation)
        super(screen_orientation)
        self.device_name = device_name
      end

      def json_data
        {
          deviceName: device_name,
          screenOrientation: screen_orientation
        }
      end
    end
  end
end
