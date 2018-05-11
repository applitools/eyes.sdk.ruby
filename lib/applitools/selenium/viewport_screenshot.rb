# frozen_string_literal: true
require_relative 'eyes_screenshot'
module Applitools::Selenium
  # @!visibility private
  class ViewportScreenshot < Applitools::Selenium::EyesScreenshot
    attr_accessor :top_left_location

    def sub_screenshot(region, _coordinate_type, throw_if_clipped = false, force_nil_if_clipped = false)
      logger.info "get_subscreenshot(#{region}, #{throw_if_clipped})"
      Applitools::ArgumentGuard.not_nil region, 'region'

      as_is_subscreenshot_region = region.intersect(image_region)

      if as_is_subscreenshot_region.empty? || (throw_if_clipped && as_is_subscreenshot_region.size != region.size)
        return nil if force_nil_if_clipped
        raise Applitools::OutOfBoundsException.new "Region #{region} is out" \
          ' of screenshot bounds.'
      end

      cropped_image = Applitools::Screenshot.from_image(
        image.crop(
          as_is_subscreenshot_region.x,
          as_is_subscreenshot_region.y,
          as_is_subscreenshot_region.width,
          as_is_subscreenshot_region.height
        )
      )

      self.class.new(cropped_image, region_provider: region_provider).tap do |s|
        s.top_left_location = top_left_location.dup.offset(region.location)
      end
    end

    def screenshot_offset
      offset = Applitools::Location::TOP_LEFT.dup
      offset.offset region_provider.scroll_position_provider.current_position
      frame_window = region_provider.calculate_frame_window
      offset.offset_negative(frame_window.location)
      offset
    end

    def top_left_location
      @top_left_location ||= screenshot_offset
    end
  end
end
