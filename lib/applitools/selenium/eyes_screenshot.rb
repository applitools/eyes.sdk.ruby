module Applitools
  module Selenium
    class EyesScreenshot < Applitools::EyesScreenshot
      attr_accessor :driver
      def_delegators '@driver', :frame_chain

      def initialize(image, options = {})
        super image
        self.driver = options[:driver] if options[:driver]
        Applitools::ArgumentGuard.is_a?(driver, 'options[:driver]', Applitools::Selenium::Driver)
      end

      def convert_location(location, _from, _to)
        location.offset_negative(top_left_location)
      end

      # Returns the location in the screenshot.
      #
      # @param [Applitools::Location] location The location.
      # @param [Applitools::EyesScreenshot::COORDINATE_TYPES] coordinate_type The type of the coordinate.
      # @return [Applitools::Location] The location instance in the screenshot.
      def location_in_screenshot(location, coordinate_type)
        raise Applitools::Selenium::UnsupportedCoordinateType, coordinate_type unless coordinate_type == Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative]

        location = convert_location(
            location, coordinate_type, Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
        )

        unless image_region.contains?(location.x, location.y)
          raise Applitools::OutOfBoundsException.new(
              "Location #{location} (#{coordinate_type}) is not visible in screenshot!"
          )
        end
        location
      end

      def intersected_region(region, original_coordinate_types, result_coordinate_types)
        raise Applitools::Selenium::UnsupportedCoordinateType, original_coordinate_types unless original_coordinate_types == Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative]
        raise Applitools::Selenium::UnsupportedCoordinateType, result_coordinate_types unless result_coordinate_types== Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]

        return Applitools::Region::EMPTY if region.empty?

        intersected_region = convert_region_location(
            region, original_coordinate_types, Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
        )

        intersected_region.intersect(image_region)
      end
    end
  end
end