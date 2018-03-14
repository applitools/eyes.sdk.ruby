# frozen_string_literal: true

module Applitools
  module Calabash
    class CalabashElement
      extend Forwardable
      attr_reader :original_element, :element_query
      def_delegators :@original_element, :[], :keys, :values

      def initialize(element, element_query)
        raise Applitools::EyesIllegalArgument, "Invalid element passed! (#{element})" unless valid_element?(element)
        @original_element = element
        @element_query = element_query
      end

      def left
        self['rect']['x']
      end

      alias x left

      def top
        self['rect']['y']
      end

      alias y top

      def width
        self['rect']['width']
      end

      def height
        self['rect']['height']
      end

      def location
        Applitools::Location.from_struct(self)
      end

      def size
        Applitools::RectangleSize.from_struct(self)
      end

      def region
        Applitools::Region.from_location_size(location, size)
      end

      def to_s
        @original_element
      end

      private

      def valid_element?(element)
        result = true
        result &&= element.is_a?(Hash)
        result &&= element.key?('rect')
        result &&= (rect = element['rect']).is_a?(Hash)
        result &&= (%w(height width y x center_x center_y) - rect.keys).empty?
        result
      end
    end
  end
end
