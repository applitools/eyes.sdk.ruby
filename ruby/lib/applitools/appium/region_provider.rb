# frozen_string_literal: true

module Applitools
  module Appium
    class RegionProvider
      attr_accessor :driver, :eye_region, :region_to_check

      def initialize(driver, eye_region)
        self.driver = driver
        self.eye_region = eye_region
        self.region_to_check = Applitools::Region::EMPTY
        convert_region_coordinates
      end

      def region
        region_to_check
      end

      def coordinate_type
        nil
      end

      private

      def viewport_rect
        Applitools::Appium::Utils.viewport_rect(driver)
      end

      def convert_region_coordinates
        self.region_to_check = case eye_region
                               when ::Selenium::WebDriver::Element, Applitools::Selenium::Element
                                  convert_element_coordinates
                               else
                                  convert_viewport_rect_coordinates
                               end
      end

      def convert_element_coordinates
        raise Applitools::AbstractMethodCalled.new(:convert_region_coordinates, 'Applitools::Appium::RegionProvider')
      end

      def convert_viewport_rect_coordinates
        raise Applitools::AbstractMethodCalled.new(:convert_viewport_rect_coordinates, 'Applitools::Appium::RegionProvider')
      end

      def scale_factor
        Applitools::Appium::Utils.device_pixel_ratio(driver)
      end
    end
  end
end
