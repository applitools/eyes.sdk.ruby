# frozen_string_literal: true

module Applitools
  module AccessibilityRegionType
    extend self

    NONE = 'None'
    IGNORE_CONTRAST = 'IgnoreContrast'
    REGULAR_TEXT = 'RegularText'
    LARGE_TEXT = 'LargeText'
    BOLD_TEXT = 'BoldText'
    GRAPHICAL_OBJECT = 'GraphicalObject'

    def enum_values
      [
        NONE,
        IGNORE_CONTRAST,
        REGULAR_TEXT,
        LARGE_TEXT,
        BOLD_TEXT,
        GRAPHICAL_OBJECT
      ]
    end
  end
end
