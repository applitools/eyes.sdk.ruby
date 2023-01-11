# frozen_string_literal: true
module Orientations
  extend self
  def const_missing(name)
    puts 'Please prefer using the Orientation instead of Orientations(plural).'
    Orientation.const_get(name)
  end
  def enum_values
    Orientation.enum_values
  end
end

module Orientation
  extend self
  PORTRAIT = 'portrait'
  LANDSCAPE = 'landscape'

  def enum_values
    [PORTRAIT, LANDSCAPE]
  end
end
