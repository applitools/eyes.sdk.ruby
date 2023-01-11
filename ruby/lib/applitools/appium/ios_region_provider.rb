# frozen_string_literal: true
#
require_relative 'region_provider'
module Applitools
  module Appium
    class IosRegionProvider < ::Applitools::Appium::RegionProvider
      private

      def convert_element_coordinates
        Applitools::Region.from_location_size(eye_region.location, eye_region.size).
            scale_it!(scale_factor)
      end

      def convert_viewport_rect_coordinates
        region  = viewport_rect
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
