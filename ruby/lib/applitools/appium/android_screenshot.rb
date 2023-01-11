require_relative './screenshot.rb'
module Applitools
  module Appium
    class AndroidScreenshot < Applitools::Appium::Screenshot
      def convert_region_location(region, from, to)
        # converted_size = region.size.dup.scale_it!(1 / device_pixel_ratio)
        # converted_location = region.location.dup.offset_negative(Applitools::Location.new(0, status_bar_height)).scale_it!(1 / device_pixel_ratio)
        # Applitools::Region.from_location_size(converted_location, converted_size)
        Applitools::Region.from_location_size(
          convert_location(region.location, nil, nil),
          region.size
        ).scale_it!(1.to_f / device_pixel_ratio)
      end

      def convert_location(location, _from, _to)
        location.offset_negative(Applitools::Location.new(0, status_bar_height))
      end

    end
  end
end