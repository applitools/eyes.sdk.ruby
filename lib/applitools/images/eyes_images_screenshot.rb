# frozen_string_literal: true

module Applitools::Images
  # @!visibility private
  class EyesImagesScreenshot < ::Applitools::EyesScreenshot
    SCREENSHOT_AS_IS = Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is].freeze
    CONTEXT_RELATIVE = Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative].freeze

    def initialize(image, options = {})
      super image
      return if (location = options[:location]).nil?
      Applitools::ArgumentGuard.is_a? location, 'options[:location]', Applitools::Location
      @bounds = Applitools::Region.new location.x, location.y, image.width, image.height
    end

    def convert_location(location, from, to)
      Applitools::ArgumentGuard.not_nil location, 'location'
      Applitools::ArgumentGuard.not_nil from, 'from'
      Applitools::ArgumentGuard.not_nil to, 'to'

      Applitools::ArgumentGuard.is_a? location, 'location', Applitools::Location

      result = Applitools::Location.new location.x, location.y
      return result if from == to

      case from
      when SCREENSHOT_AS_IS
        raise "Coordinate type conversation error: #{from} -> #{to}" unless to == CONTEXT_RELATIVE
        result.offset bounds
        return result
      when CONTEXT_RELATIVE
        raise "Coordinate type conversation error: #{from} -> #{to}" unless to == SCREENSHOT_AS_IS
        result.offset(Applitools::Location.new(-bounds.x, -bounds.y))
        return result
      else
        raise "Coordinate type conversation error: #{from} -> #{to}"
      end
    end

    def intersected_region(region, from, to = CONTEXT_RELATIVE)
      Applitools::ArgumentGuard.not_nil region, 'region'
      Applitools::ArgumentGuard.not_nil from, 'coordinates Type (from)'

      return Applitools::Region.new(0, 0, 0, 0) if region.empty?

      intersected_region = convert_region_location region, from, to
      intersected_region.intersect bounds
      return intersected_region if intersected_region.empty?

      intersected_region.location = convert_location intersected_region.location, to, from
      intersected_region
    end

    def location_in_screenshot(location, coordinates_type)
      Applitools::ArgumentGuard.not_nil location, 'location'
      Applitools::ArgumentGuard.not_nil coordinates_type, 'coordinates_type'
      location = convert_location(location, coordinates_type, CONTEXT_RELATIVE)

      unless bounds.contains? location.left, location.top
        raise Applitools::OutOfBoundsException.new "Location #{location} is not available in screenshot!"
      end

      convert_location location, CONTEXT_RELATIVE, SCREENSHOT_AS_IS
    end

    def sub_screenshot(region, coordinates_type, throw_if_clipped = false, force_nil_if_clipped = false)
      Applitools::ArgumentGuard.not_nil region, 'region'
      Applitools::ArgumentGuard.not_nil coordinates_type, 'coordinates_type'

      sub_screen_region = intersected_region region, coordinates_type, SCREENSHOT_AS_IS

      if sub_screen_region.empty? || (throw_if_clipped && !region.size_equals?(sub_screen_region))
        return nil if force_nil_if_clipped
        Applitools::OutOfBoundsException.new "Region #{sub_screen_region} (#{coordinates_type}) is out of " \
          " screenshot bounds #{bounds}"
      end

      sub_screenshot_image = Applitools::Screenshot.from_any_image(
        image.crop(
          sub_screen_region.left, sub_screen_region.top, sub_screen_region.width, sub_screen_region.height
        ).to_datastream.to_blob
      )

      relative_sub_screenshot_region = convert_region_location(sub_screen_region, SCREENSHOT_AS_IS, CONTEXT_RELATIVE)

      Applitools::Images::EyesImagesScreenshot.new sub_screenshot_image,
        location: relative_sub_screenshot_region.location
    end

    private

    def bounds
      @bounds ||= Applitools::Region.new(0, 0, image.width, image.height)
    end
  end
end
