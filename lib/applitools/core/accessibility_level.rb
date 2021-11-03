# frozen_string_literal: true

module Applitools
  module AccessibilityLevel
    extend self
    AA = 'AA'
    AAA = 'AAA'

    def enum_values
      [AA, AAA]
    end
  end

  module AccessibilityGuidelinesVersion
    extend self
    WCAG_2_1 = 'WCAG_2_1'
    WCAG_2_0 = 'WCAG_2_0'
    def enum_values
      [WCAG_2_0, WCAG_2_1]
    end
  end

  class AccessibilitySettings
    attr_reader :config_hash
    attr_accessor :validation_errors
    extend Applitools::EyesConfigurationDSL

    enum_field :level, Applitools::AccessibilityLevel.enum_values
    enum_field :version, Applitools::AccessibilityGuidelinesVersion.enum_values

    def initialize(accessibility_level, guidelines_version)
      @config_hash = {}
      self.validation_errors = []
      self.level = accessibility_level
      self.version = guidelines_version
    end

    def to_h
      @config_hash
    end

    def json_data
      to_h
    end

    # accessibilitySettings?: {
    #   level?: AccessibilityLevel
    #   guidelinesVersion?: AccessibilityGuidelinesVersion
    # }
    def to_hash
      {
        level: level,
        guidelinesVersion: version
      }
    end
  end
end
