# frozen_string_literal: false

module Applitools
  module MatchLevel
    extend self
    NONE = 'None'.freeze
    LAYOUT = 'Layout'.freeze
    LAYOUT1 = 'Layout1'.freeze
    LAYOUT2 = 'Layout2'.freeze
    CONTENT = 'Content'.freeze
    IGNORE_COLORS = 'IgnoreColors'.freeze
    STRICT = 'Strict'.freeze
    EXACT = 'Exact'.freeze

    def enum_values
      [NONE, LAYOUT, LAYOUT1, LAYOUT2, CONTENT, IGNORE_COLORS, STRICT, EXACT]
    end
  end
end
# U-Notes : Added Layout1 MatchLevel