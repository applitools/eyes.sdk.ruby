# frozen_string_literal: true
module Applitools
  module Selenium
    class RenderInfo
      include Applitools::Jsonable
      json_fields :width, :height, :sizeMode, :emulationInfo, :region, :selector, :IosDeviceInfo
      # , :region, :emulationInfo

      def json_data
        result = {
          width: width,
          height: height,
          sizeMode: size_mode
        }
        result['emulationInfo'] = json_value(emulation_info) if emulation_info
        result['iosDeviceInfo'] = json_value(ios_device_info) if ios_device_info
        result['region'] = json_value(region) if size_mode == 'region'
        result['selector'] = json_value(region) if size_mode == 'selector'
        result['selector'] = json_value(region) if size_mode == 'full-selector'
        result
      end
    end
  end
end
