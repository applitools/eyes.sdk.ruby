# frozen_string_literal: true

module Applitools
  class PaddingBounds
    attr_accessor :padding_left, :padding_top, :padding_right, :padding_bottom
    def initialize(padding_left, padding_top, padding_right, padding_bottom)
      Applitools::ArgumentGuard.is_a?(padding_left, 'padding_left', Integer)
      Applitools::ArgumentGuard.is_a?(padding_top, 'padding_top', Integer)
      Applitools::ArgumentGuard.is_a?(padding_right, 'padding_right', Integer)
      Applitools::ArgumentGuard.is_a?(padding_bottom, 'padding_bottom', Integer)

      Applitools::ArgumentGuard.greater_than_or_equal_to_zero(padding_left, 'padding_left')
      Applitools::ArgumentGuard.greater_than_or_equal_to_zero(padding_top, 'padding_top')
      Applitools::ArgumentGuard.greater_than_or_equal_to_zero(padding_right, 'padding_right')
      Applitools::ArgumentGuard.greater_than_or_equal_to_zero(padding_bottom, 'padding_bottom')

      self.padding_left = padding_left
      self.padding_top = padding_top
      self.padding_right = padding_right
      self.padding_bottom = padding_bottom
    end

    ZERO_PADDING = PaddingBounds.new(0, 0, 0, 0).freeze
    PIXEL_PADDING = PaddingBounds.new(1, 1, 1, 1).freeze
  end
end
