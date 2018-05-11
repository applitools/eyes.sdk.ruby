# frozen_string_literal: true
require_relative 'eyes_screenshot'
module Applitools::Selenium
  class FullpageScreenshot < Applitools::Selenium::EyesScreenshot
    def sub_screenshot(region, _coordinate_type, throw_if_clipped = false, force_nil_if_clipped = false)
      logger.info "get_subscreenshot(#{region}, #{throw_if_clipped})"
      Applitools::ArgumentGuard.not_nil region, 'region'

      as_is_subscreenshot_region = region.intersect(image_region)

      if as_is_subscreenshot_region.empty? || (throw_if_clipped && as_is_subscreenshot_region.size != region.size)
        return nil if force_nil_if_clipped
        raise Applitools::OutOfBoundsException.new "Region #{region} is out" \
          ' of screenshot bounds'
      end

      sub_screenshot_image = Applitools::Screenshot.from_image(
        image.crop(
          as_is_subscreenshot_region.left,
          as_is_subscreenshot_region.top,
          as_is_subscreenshot_region.width,
          as_is_subscreenshot_region.height
        )
      )

      result = self.class.new(sub_screenshot_image, region_provider: region_provider)
      logger.info 'Done!'
      result
    end

    def top_left_location
      @top_left_location ||= Applitools::Location::TOP_LEFT
    end
  end
end
