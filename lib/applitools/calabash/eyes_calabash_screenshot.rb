module Applitools
  module Calabash
    class EyesCalabashScreenshot < Applitools::EyesScreenshot
      SCREENSHOT_AS_IS = Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is].freeze
      CONTEXT_RELATIVE = Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative].freeze
      DRIVER = 'DRIVER'.freeze

      attr_reader :scale_factor

      def initialize(image, options = {})
        super image
        @scale_factor = options[:scale_factor] || 1
        # return if (location = options[:location]).nil?
        # Applitools::ArgumentGuard.is_a? location, 'options[:location]', Applitools::Location
        # @bounds = Applitools::Region.new location.x, location.y, image.width, image.height
      end

      def sub_screenshot(region, coordinates_type, throw_if_clipped = false, force_nil_if_clipped = false)
        Applitools::ArgumentGuard.not_nil region, 'region'
        Applitools::ArgumentGuard.not_nil coordinates_type, 'coordinates_type'

        sub_screen_region = intersected_region region, coordinates_type, SCREENSHOT_AS_IS

        if sub_screen_region.empty? || (throw_if_clipped && !region.size_equals?(sub_screen_region))
          return nil if force_nil_if_clipped
          raise Applitools::OutOfBoundsException, "Region #{sub_screen_region} (#{coordinates_type}) is out of " \
          " screenshot bounds #{bounds}"
        end

        sub_screenshot_image = Applitools::Screenshot.from_any_image(
          image.crop(
            sub_screen_region.left, sub_screen_region.top, sub_screen_region.width, sub_screen_region.height
          ).to_datastream.to_blob
        )

        self.class.new sub_screenshot_image, scale_factor: scale_factor
      end

      def location_in_screenshot(_location, _coordinates_type)
        raise(
          Applitools::EyesError,
          'Call to :convert_location is prohibited for Applitools::Calabash::EyesCalabashScreenshot'
        )
      end

      def intersected_region(region, from, to = CONTEXT_RELATIVE)
        Applitools::ArgumentGuard.not_nil region, 'region'
        Applitools::ArgumentGuard.not_nil from, 'coordinates Type (from)'
        return Applitools::Region.new(0, 0, 0, 0) if region.empty?
        intersected_region = convert_region_location region, from, to
        intersected_region.intersect bounds
        intersected_region
      end

      def convert_location(_location, _from, _to)
        raise(
          Applitools::EyesError,
          'Call to :convert_location is prohibited for Applitools::Calabash::EyesCalabashScreenshot'
        )
      end

      abstract_method :convert_region_location, false

      def scale_it!
        width = (image.width.to_f / scale_factor).to_i
        height = (image.height.to_f / scale_factor).to_i
        image.resample_bicubic!(width, height)
        self
      end

      private

      def bounds
        @bounds ||= Applitools::Region.new(0, 0, image.width, image.height)
      end
    end
  end
end
