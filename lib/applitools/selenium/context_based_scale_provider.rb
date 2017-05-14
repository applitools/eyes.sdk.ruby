module Applitools::Selenium
  # @!visibility private
  class ContextBasedScaleProvider
    UNKNOWN_SCALE_RATIO = 0
    ALLOWED_VS_DEVIATION = 1
    ALLOWED_DCES_DEVIATION = 10

    attr_reader :top_level_context_entire_size, :viewport_size, :device_pixel_ratio, :scale_ratio

    # Initialize a class instance.
    #
    # @param [Applitools::RectangleSize] top_level_context_entire_size The entire
    # size of the context.
    # @param [Hash] viewport_size The required browser's viewport size.
    # @param [Fixnum] device_pixel_ratio The device's pixel ratio.
    def initialize(top_level_context_entire_size, viewport_size, device_pixel_ratio)
      @top_level_context_entire_size = top_level_context_entire_size
      @viewport_size = viewport_size
      @device_pixel_ratio = device_pixel_ratio
      @scale_ratio = UNKNOWN_SCALE_RATIO
    end

    # Scales the image.
    #
    # @param [Screenshot::Datastream] image The image to scale.
    def scale_image(image)
      if @scale_ratio == UNKNOWN_SCALE_RATIO
        @scale_ratio = if ((image.width >= viewport_size.width - ALLOWED_VS_DEVIATION) &&
            (image.width <= viewport_size.width + ALLOWED_VS_DEVIATION)) ||
            ((image.width >= top_level_context_entire_size.width - ALLOWED_DCES_DEVIATION) &&
            (image.width <= top_level_context_entire_size.width + ALLOWED_DCES_DEVIATION))
                         1
                       else
                         1.to_f / device_pixel_ratio
                       end
      end
      Applitools::Utils::ImageUtils.scale!(image, scale_ratio)
    end

    # Gets the scale ratio.
    #
    # @return [Fixnum] The scale ratio.
    def scale_ratio
      raise Applitools::EyesError.new 'Scale ratio is not defined yet!' if @scale_ratio == UNKNOWN_SCALE_RATIO
      @scale_ratio
    end
  end
end
