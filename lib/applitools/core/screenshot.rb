module Applitools
  class Screenshot < Delegator
    class << self
      def from_region(region)
        self::Image.new(::ChunkyPNG::Image.new(region.width, region.height))
      end

      def from_datastream(datastream)
        self::Datastream.new(datastream)
      end

      def from_image(image)
        Image.new(image)
      end

      def from_any_image(image)
        return from_region(image) if image.is_a? Applitools::Region
        return from_image(image) if image.is_a? ::ChunkyPNG::Image
        return image if image.is_a?(Image) |
            image.is_a?(Datastream) | image.is_a?(ScaledImage) | image.is_a?(ScaledDatastream)
        from_datastream(image)
      end
    end

    def initialize(_image)
      raise Applitools::EyesError.new 'Applitools::Screenshot is an abstract class!'
    end

    def __getobj__
      nil
    end

    def method_missing(method, *args, &block)
      if method =~ /^.+!$/
        __setobj__ super
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      super
    end

    class Datastream < self
      extend Forwardable
      def_delegators :header, :width, :height
      attr_reader :datastream

      def initialize(image)
        Applitools::ArgumentGuard.not_nil(image, 'image')
        unless image.is_a?(String)
          Applitools::ArgumentGuard.raise_argument_error(
            "Expected image to be Datastream or String, but got #{image.class}"
          )
        end
        @datastream = ::ChunkyPNG::Datastream.from_string image
      end

      def update!(image)
        Applitools::ArgumentGuard.not_nil(image, 'image')
        Applitools::ArgumentGuard.is_a?(image, 'image', ::ChunkyPNG::Image)
        @datastream = image.to_datastream
        self
      end

      def to_blob
        @datastream.to_blob
      end

      def header
        @datastream.header_chunk
      end

      def __getobj__
        restore
      end

      alias image __getobj__

      def __setobj__(obj)
        @datastream = obj.to_datastream
        self
      end

      def restore
        ::ChunkyPNG::Image.from_datastream @datastream
      end
    end

    class Image < self
      attr_reader :image

      def initialize(image)
        Applitools::ArgumentGuard.not_nil(image, 'image')
        Applitools::ArgumentGuard.is_a?(image, 'image', ::ChunkyPNG::Image)
        @image = image
      end

      def update!(image)
        Applitools::ArgumentGuard.not_nil(image, 'image')
        Applitools::ArgumentGuard.is_a?(image, 'image', ::ChunkyPNG::Image)
        @image = image
      end

      def __getobj__
        @image
      end

      def __setobj__(obj)
        @image = obj
      end
    end

    module ScaledCanvas
      def self.included(base)
        base.instance_eval do
          attr_reader :device_pixel_ratio
        end
      end

      def initialize(image, device_pixel_ratio)
        Applitools::ArgumentGuard.not_nil(device_pixel_ratio, :device_pixel_ratio)
        Applitools::ArgumentGuard.is_a?(device_pixel_ratio, :device_pixel_ratio, Float)
        super(image)
        @device_pixel_ratio = device_pixel_ratio
      end

      def replace!(new_image, left, top)
        image.replace!(new_image.image, pixel_size(left), pixel_size(top))
      rescue
        old_image = image

        if pixel_size(left) + new_image.image.width > image.width
          __setobj__(ChunkyPNG::Image.new(pixel_size(left) + new_image.image.width, image.height))
        end

        if pixel_size(top) + new_image.image.height > image.height
          __setobj__(ChunkyPNG::Image.new(image.width, pixel_size(top) + new_image.image.height))
        end

        image.replace!(old_image, 0, 0)
        image.replace!(new_image.image, pixel_size(left), pixel_size(top))
      ensure
        self
      end

      def crop!(left, top, width, height)
        super(pixel_size(left), pixel_size(top), pixel_size(width), pixel_size(height))
        self
      end

      def crop(*args)
        dup.crop!(*args)
      end

      def replace(*args)
        dup.replace!(*args)
      end

      def pixel_size(value)
        (value.to_f * device_pixel_ratio).round
      end

      def width
        (super.to_f / device_pixel_ratio).floor
      end

      def height
        (super.to_f / device_pixel_ratio).floor
      end
    end

    class ScaledImage < Applitools::Screenshot::Image
      include ScaledCanvas
    end

    class ScaledDatastream < Applitools::Screenshot::Datastream
      include ScaledCanvas
    end
  end
end
