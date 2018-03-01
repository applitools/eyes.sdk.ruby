# frozen_string_literal: true

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
        return image if image.is_a?(Image) | image.is_a?(Datastream)
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
  end
end
