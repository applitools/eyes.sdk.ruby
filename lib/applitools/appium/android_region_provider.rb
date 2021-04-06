# frozen_string_literal: true

require_relative 'region_provider'
module Applitools
  module Appium
    class AndroidRegionProvider < ::Applitools::Appium::RegionProvider
      private

      def convert_element_coordinates
        Applitools::Region.from_location_size(eye_region.location, eye_region.size)
      end

      def convert_viewport_rect_coordinates
        region  = viewport_rect

        session_info = Applitools::Appium::Utils.session_capabilities(driver)
        if session_info['deviceScreenSize']
          device_height = session_info['deviceScreenSize'].split('x').last.to_i
          system_bars_height = driver.get_system_bars.map {|_,v| v['height'] }.sum
          region['height'] = device_height - system_bars_height
        end

        Applitools::Region.new(
            region['left'],
            region['top'],
            region['width'],
            region['height']
        )
      end
    end
  end
end
