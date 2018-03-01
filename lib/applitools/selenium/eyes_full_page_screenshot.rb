# frozen_string_literal: true

module Applitools::Selenium
  class EyesFullPageScreenshot < Applitools::EyesScreenshot
    def initialize(*args)
      super
    end

    def sub_screenshot(region, coordinate_type, throw_if_clipped = false, force_nil_if_clipped = false)
      logger.info "get_subscreenshot(#{region}, #{coordinate_type}, #{throw_if_clipped})"
      Applitools::ArgumentGuard.not_nil region, 'region'
      Applitools::ArgumentGuard.not_nil coordinate_type, 'coordinate_type'

      as_is_subscreenshot_region = intersected_region(
        region, coordinate_type,
        Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
      )

      if as_is_subscreenshot_region.empty? || (throw_if_clipped && as_is_subscreenshot_region.size != region.size)
        return nil if force_nil_if_clipped
        raise Applitools::OutOfBoundsException.new "Region #{region} (#{coordinate_type}) is out" \
          " of screenshot bounds [#{frame_window}]"
      end

      sub_screenshot_image = Applitools::Screenshot.from_image(
        image.crop(
          as_is_subscreenshot_region.left,
          as_is_subscreenshot_region.top, as_is_subscreenshot_region.width,
          as_is_subscreenshot_region.height
        )
      )
      result = self.class.new sub_screenshot_image
      logger.info 'Done!'
      result
    end

    def intersected_region(region, _original_coordinate_types, _result_coordinate_types)
      region.intersect Applitools::Region.new(0, 0, image.width, image.height)
    end

    def convert_location(location, _from, _to)
      location
    end

    def location_in_screenshot(location, _coordinate_type)
      location
    end
  end
end
