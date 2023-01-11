# frozen_string_literal: true

require_relative 'jsonable'

module Applitools
  class ImageMatchSettings
    include Applitools::Jsonable
    include Applitools::MatchLevelSetter
    json_fields :accessibilitySettings, :MatchLevel, :IgnoreCaret, :IgnoreDisplacements, :Accessibility,
      :Ignore, :Floating, :Layout, :Strict, :Content, :Exact, :EnablePatterns, :UseDom,
      :SplitTopHeight, :SplitBottomHeight, :scale, :remainder

    def initialize
      self.accessibility_settings = nil
      self.match_level = Applitools::MatchLevel::STRICT
      self.split_top_height = 0
      self.split_bottom_height = 0
      self.ignore_caret = true
      self.ignore_displacements = false
      self.accessibility = []
      self.ignore = []
      self.floating = []
      self.layout = []
      self.strict = []
      self.content = []
      self.exact = Exact.new
      self.scale = 0
      self.remainder = 0
      self.enable_patterns = false
      self.use_dom = false
    end

    def set_match_level(value, exact_options = {})
      (self.match_level, self.exact) = match_level_with_exact(value, exact_options)
      match_level
    end

    def deep_dup
      cloned_value = self.class.new
      self.class.json_methods.keys.each do |f|
        new_value = case (v = send(f))
                    when Symbol, FalseClass, TrueClass, Integer, Float, NilClass
                      v
                    else
                      v.clone
                    end
        cloned_value.send("#{f}=", new_value)
      end
      cloned_value
    end

    def accessibility_validation
      accessibility_settings
    end

    def accessibility_validation=(value)
      raise Applitools::EyesIllegalArgument, "Expected value to be an Applitools::AccessibilitySettings instance but got #{value.class}" unless value.nil? || value.is_a?(Applitools::AccessibilitySettings)
      self.accessibility_settings = value
    end

    def ==(other)
      return true if other.object_id == object_id
      result = true
      self.class.json_methods.keys.each do |f|
        result = send(f) == other.send(f)
        break unless result
      end
      result
    end

    alias deep_clone deep_dup

    class Exact
      include Applitools::Jsonable
      json_fields :MinDiffIntensity, :MinDiffWidth, :MinDiffHeight, :MatchThreshold

      class << self
        def from_exact_options(options)
          new.tap do |exact|
            exact.min_diff_intensity = options['MinDiffIntensity']
            exact.min_diff_width = options['MinDiffWidth']
            exact.min_diff_height = options['MinDiffHeight']
            exact.match_threshold = options['MatchThreshold']
          end
        end
      end

      def initialize
        self.min_diff_intensity = 0
        self.min_diff_width = 0
        self.min_diff_height = 0
        self.match_threshold = 0
      end

      def ==(other)
        min_diff_intensity == other.min_diff_intensity &&
          min_diff_width == other.min_diff_width &&
          min_diff_height == other.min_diff_height &&
          match_threshold == other.match_threshold
      end

      def to_hash
        {
          minDiffIntensity: min_diff_intensity,
          minDiffWidth: min_diff_width,
          minDiffHeight: min_diff_height,
          matchThreshold: match_threshold
        }
      end
    end

    # export type MatchSettings<TRegion> = {
    #   exact?: {
    #     minDiffIntensity: number
    #     minDiffWidth: number
    #     minDiffHeight: number
    #     matchThreshold: number
    #   }
    #   matchLevel?: MatchLevel
    #   sendDom?: boolean
    #   useDom?: boolean
    #   enablePatterns?: boolean
    #   ignoreCaret?: boolean
    #   ignoreDisplacements?: boolean
    #   accessibilitySettings?: {
    #     level?: AccessibilityLevel
    #     guidelinesVersion?: AccessibilityGuidelinesVersion
    #   }
    #   ignoreRegions?: TRegion[]
    #   layoutRegions?: TRegion[]
    #   strictRegions?: TRegion[]
    #   contentRegions?: TRegion[]
    #   floatingRegions?: (TRegion | FloatingRegion<TRegion>)[]
    #   accessibilityRegions?: (TRegion | AccessibilityRegion<TRegion>)[]
    # }
    def to_hash
      result = {}
      result[:exact] = exact.to_hash unless exact == Exact.new # ...
      result[:matchLevel] = match_level
      # result[:sendDom] = nil # duplicate configuration ?
      result[:useDom] = use_dom if use_dom
      result[:enablePatterns] = enable_patterns if enable_patterns
      result[:ignoreCaret] = ignore_caret if ignore_caret
      result[:ignoreDisplacements] = ignore_displacements if ignore_displacements
      result[:accessibilitySettings] = accessibility_settings.to_hash if accessibility_settings
      result[:ignoreRegions] = ignore unless ignore.empty?
      result[:layoutRegions] = layout unless layout.empty?
      result[:strictRegions] = strict unless strict.empty?
      result[:contentRegions] = content unless content.empty?
      result[:floatingRegions] = floating unless floating.empty?
      result[:accessibilityRegions] = accessibility unless accessibility.empty?
      result.compact
      # :SplitTopHeight, :SplitBottomHeight, :scale, :remainder - deprecated ?
    end

  end
end
