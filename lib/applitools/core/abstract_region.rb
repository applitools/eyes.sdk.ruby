# frozen_string_literal: true

module Applitools
  class AbstractRegion
    class << self
      def ===(other)
        result = true
        result &&= other.respond_to?(:location)
        result &&= other.respond_to?(:size)
        result &&= other.location.respond_to?(:x)
        result &&= other.location.respond_to?(:y)
        result &&= other.size.respond_to?(:width)
        result &&= other.size.respond_to?(:height)
        result
      end
    end
  end
end
