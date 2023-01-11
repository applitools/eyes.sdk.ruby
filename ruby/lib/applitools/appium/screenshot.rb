# frozen_string_literal: true

module Applitools
  module Appium
    class Screenshot < Applitools::EyesScreenshot

      attr_reader :status_bar_height, :device_pixel_ratio

      def initialize(*args)
        options = Applitools::Utils.extract_options!(args)
        @status_bar_height = options[:status_bar_height] || 0
        @device_pixel_ratio = options[:device_pixel_ratio] || 1
        super
      end

      def sub_screenshot(region, _coordinate_type, _throw_if_clipped = false, _force_nil_if_clipped = false)
        self.class.new(
          Applitools::Screenshot.from_image(
            image.crop(region.x, region.y, region.width, region.height)
          )
        )
      end

      def convert_location(location, _from, _to)
        raise 'Applitools::Appium::Screenshot is an abstract class.' \
          ' You should implement :convert_location method in a descendant class.'
      end
    end
  end
end
