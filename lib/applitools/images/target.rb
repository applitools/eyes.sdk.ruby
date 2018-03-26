# frozen_string_literal: true

module Applitools::Images
  class Target
    include Applitools::FluentInterface
    class << self
      def path(path)
        raise Applitools::EyesIllegalArgument unless File.exist?(path)
        new Applitools::Screenshot.from_image(ChunkyPNG::Image.from_file(path))
      end

      def blob(blob_image)
        Applitools::ArgumentGuard.not_nil blob_image, 'blob_image'
        Applitools::ArgumentGuard.is_a? blob_image, 'blob_image', String
        new Applitools::Screenshot.from_datastream(blob_image)
      end

      def image(image)
        Applitools::ArgumentGuard.not_nil image, 'image'
        Applitools::ArgumentGuard.is_a? image, 'image', ChunkyPNG::Image
        new Applitools::Screenshot.from_image(image)
      end

      def screenshot(screenshot)
        Applitools::ArgumentGuard.not_nil screenshot, 'screenshot'
        Applitools::ArgumentGuard.is_a? screenshot, 'screenshot', Applitools::Screenshot
        new screenshot
      end

      def any(screenshot)
        case screenshot
        when Applitools::Screenshot
          screenshot(screenshot)
        when ChunkyPNG::Image
          image(screenshot)
        when String
          begin
            blob(screenshot)
          rescue ChunkyPNG::SignatureMismatch
            path(screenshot)
          end
        else
          raise Applitools::EyesIllegalArgument.new "Passed screenshot is not image type (#{screenshot.class})"
        end
      end
    end

    attr_accessor :image, :options, :ignored_regions, :region_to_check, :floating_regions

    def initialize(image)
      Applitools::ArgumentGuard.not_nil(image, 'image')
      Applitools::ArgumentGuard.is_a? image, 'image', Applitools::Screenshot
      self.image = image
      self.ignored_regions = []
      self.floating_regions = []
      self.options = {
        trim: false
      }
    end

    def ignore(*args)
      requested_padding = if args.last.is_a? Applitools::PaddingBounds
                            args.pop
                          else
                            Applitools::PaddingBounds::PIXEL_PADDING
                          end
      region = args.shift
      if region
        Applitools::ArgumentGuard.is_a? region, 'region', Applitools::Region
        ignored_regions << region.padding(requested_padding)
      else
        self.ignored_regions = []
      end
      self
    end

    def floating(*args)
      requested_padding = if args.last.is_a? Applitools::PaddingBounds
                            args.pop
                          else
                            Applitools::PaddingBounds::PIXEL_PADDING
                          end

      value = case args.first
              when Applitools::FloatingRegion
                proc { args.first.padding(requested_padding) }
              when Applitools::Region
                proc do
                  region = args.shift
                  Applitools::FloatingRegion.any(region, *args).padding(requested_padding)
                end
              else
                self.floating_regions = []
              end
      floating_regions << value
      self
    end

    def region(region = nil)
      if region
        Applitools::ArgumentGuard.is_a? region, 'region', Applitools::Region
        self.region_to_check = region
      else
        self.region_to_check = nil
      end
      self
    end
  end
end
