# frozen_string_literal: true

module Applitools
  # @!visibility private
  class FixedScaleProvider
    attr_reader :scale_ratio, :scale_method
    def initialize(scale_ratio, method = :speed)
      @scale_ratio = scale_ratio
      @scale_method = method
    end

    def scale_image(image)
      Applitools::Utils::ImageUtils.scale!(image, scale_ratio)
    end
  end
end
