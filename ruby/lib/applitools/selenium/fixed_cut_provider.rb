# frozen_string_literal: true

module Applitools
  module Selenium
    class FixedCutProvider
      class << self
        def viewport(image, viewport_size, region_to_check)
          return nil if image.square == viewport_size.square
          current_scroll_position = region_to_check.scroll_position_provider.current_position
          image_canvas = Applitools::Region.new(0, 0, image.width, image.height)
          viewport_frame = image_canvas.dup.intersect(
            Applitools::Region.from_location_size(
              Applitools::Location.new(current_scroll_position.left, current_scroll_position.top),
              viewport_size
            )
          )
          new(
            viewport_frame.left,
            viewport_frame.top,
            image_canvas.right - viewport_frame.right,
            image_canvas.bottom - viewport_frame.bottom
          )
        end
      end

      def initialize(left, header, right, footer)
        Applitools::ArgumentGuard.is_a?(left, 'left', Integer)
        Applitools::ArgumentGuard.is_a?(header, 'header', Integer)
        Applitools::ArgumentGuard.is_a?(right, 'right', Integer)
        Applitools::ArgumentGuard.is_a?(footer, 'footer', Integer)
        self.left = left
        self.header = header
        self.right = right
        self.footer = footer
      end

      def cut(image)
        crop_width = image.width - left - right
        crop_height = image.height - header - footer
        image.crop!(left, header, crop_width, crop_height)
      end

      private

      attr_accessor :left, :header, :right, :footer
    end
  end
end
