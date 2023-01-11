# frozen_string_literal: true

module Applitools
  class EyesScreenshot
    extend Forwardable
    extend Applitools::Helpers

    def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=
    attr_accessor :image, :top_left_location
    def_delegators '@image', :width, :height

    COORDINATE_TYPES = {
      context_as_is: 'CONTEXT_AS_IS',
      screenshot_as_is: 'SCREENSHOT_AS_IS',
      context_relative: 'CONTEXT_RELATIVE'
    }.freeze

    def initialize(screenshot)
      Applitools::ArgumentGuard.is_a? screenshot, 'screenshot', Applitools::Screenshot
      self.image = screenshot
    end

    abstract_method :sub_screenshot, false
    abstract_method :convert_location, false
    abstract_method :location_in_screenshot, false
    abstract_method :intersected_region, false

    def sub_screenshots(regions, coordinate_type)
      Applitools::ArgumentGuard.is_a? regions, 'regions', Enumerable
      regions.map do |region|
        sub_screenshot(region, coordinate_type, false, true)
      end
    end

    def convert_region_location(region, from, to)
      Applitools::ArgumentGuard.not_nil region, 'region'
      Applitools::ArgumentGuard.is_a? region, 'region', Applitools::Region
      if region.empty?
        return region.dup.tap do |r|
          r.left = 0
          r.top = 0
          r.width = 0
          r.height = 0
        end
      end
      Applitools::ArgumentGuard.not_nil from, 'from'
      Applitools::ArgumentGuard.not_nil to, 'to'

      updated_location = convert_location(region.location, from, to)
      region.dup.tap do |r|
        r.left = updated_location.x
        r.top = updated_location.y
      end
    end

    private

    def image_region
      Applitools::Region.new(0, 0, image.width, image.height)
    end
  end
end
