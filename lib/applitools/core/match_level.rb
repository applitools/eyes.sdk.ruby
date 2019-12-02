# frozen_string_literal: false

module Applitools
  module MatchLevel
    extend self
    NONE = 'None'.freeze
    LAYOUT = 'Layout'.freeze
    LAYOUT2 = 'Layout2'.freeze
    CONTENT = 'Content'.freeze
    STRICT = 'Strict'.freeze
    EXACT = 'Exact'.freeze

    def enum_values
      [NONE, LAYOUT, LAYOUT2, CONTENT, STRICT, EXACT]
    end
  end
end
