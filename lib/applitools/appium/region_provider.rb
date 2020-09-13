# frozen_string_literal: true

module Applitools
  module Appium
    class RegionProvider
      attr_accessor :driver, :eye_region, :region_to_check, :server_device_parameters

      def initialize(driver, eye_region, server_device_parameters = {})
        self.driver = driver
        self.eye_region = eye_region
        self.region_to_check = Applitools::Region::EMPTY
        self.server_device_parameters = server_device_parameters
        convert_region_coordinates
      end

      def region
        region_to_check
      end

      def coordinate_type
        nil
      end
      
      def to_s
        region.to_s+"(#{eye_region.to_s})"
      end

      private

      def viewport_rect
        Applitools::Utils::EyesSeleniumUtils.viewport_rect(driver, server_device_parameters)
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
        Applitools::Utils::EyesSeleniumUtils.device_pixel_ratio(driver)
      end
    end
  end
end
