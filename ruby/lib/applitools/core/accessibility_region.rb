# frozen_string_literal: true

require_relative 'region'

module Applitools
  class AccessibilityRegion < ::Applitools::Region
    attr_accessor :region_type
    def initialize(element, region_type)
      super(element.location.x, element.location.y, element.size.width, element.size.height)
      self.region_type = region_type
    end

    def to_hash
      super.merge(type: region_type)
    end

    def with_padding
      self
    end

    def ==(other)
      super && region_type == other.region_type
    end
  end
end
