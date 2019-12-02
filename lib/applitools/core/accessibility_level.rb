# frozen_string_literal: true

module Applitools
  module AccessibilityLevel
    extend self
    NONE = 'None'
    AA = 'AA'
    AAA = 'AAA'

    def enum_values
      [NONE, AA, AAA]
    end
  end
end
