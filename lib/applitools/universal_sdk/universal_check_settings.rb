# frozen_string_literal: true

module Applitools
  class UniversalCheckSettings
    include Applitools::Jsonable

    # export type CheckSettings<TElement, TSelector> = MatchSettings<RegionReference<TElement, TSelector>> &
    #   ScreenshotSettings<TElement, TSelector> & {
    #     name?: string
    #     disableBrowserFetching?: boolean
    #     layoutBreakpoints?: boolean | number[]
    #     visualGridOptions?: {[key: string]: any}
    #     hooks?: {beforeCaptureScreenshot: string}
    #     pageId?: string
    #     renderId?: string
    #     variationGroupId?: string
    #     timeout?: number
    #     waitBeforeCapture?: number,
    #     lazyLoad?: boolean | LazyLoadOptions
    #   }
    json_fields :name,
      :disableBrowserFetching,
      :layoutBreakpoints,
      :visualGridOptions,
      :hooks,
      :pageId,
      :renderId,
      :variationGroupId,
      :timeout,
      :waitBeforeCapture,
      :lazyLoad

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
    json_fields :exact,
      :matchLevel,
      :sendDom,
      :useDom,
      :enablePatterns,
      :ignoreCaret,
      :ignoreDisplacements,
      :accessibilitySettings,
      :ignoreRegions,
      :layoutRegions,
      :strictRegions,
      :contentRegions,
      :floatingRegions,
      :accessibilityRegions

    # export type ScreenshotSettings<TElement, TSelector> = {
    #   region?: RegionReference<TElement, TSelector>
    #   frames?: (ContextReference<TElement, TSelector> | FrameReference<TElement, TSelector>)[]
    #   scrollRootElement?: ElementReference<TElement, TSelector>
    #   fully?: boolean
    # }
    json_fields :region,
      :frames,
      :scrollRootElement,
      :fully

    # v3
    json_fields :ufgOptions,
                :userCommandId

    # ImageTarget
    json_fields :image
                # :name,
                # :source,
                # :dom,
                # :locationInViewport,
                # :locationInView,
                # :fullViewSize

    def initialize(*args)
      options = Applitools::Utils.extract_options! args
      options.keys.select {|k| options[k] && respond_to?("#{k}=") }.each {|k| send("#{k}=", options[k]) }

      # self.timeout = Applitools::Connectivity::ServerConnector::DEFAULT_TIMEOUT
    end

    def normalize_element_selector(element)
      if element.is_a?(::Selenium::WebDriver::Element) || element.is_a?(Applitools::Selenium::Element)
        ref = element.ref
        ref = element.ref[1] if ref.is_a?(Array) && ref[0] === :element
        return { elementId: ref }
      else
        element
      end
    end

    def from_original_target(target, eyes)
      # require('pry')
      # binding.pry
      return from_eyes_images(target, eyes) if eyes.class.name === 'Applitools::Images::Eyes'

      self.accessibility_settings = eyes.accessibility_validation
      self.disable_browser_fetching = eyes.dont_fetch_resources

      self.accessibility_regions = target.accessibility_regions
      self.content_regions = target.content_regions
      self.floating_regions = target.floating_regions

      if target.respond_to?(:frames)
        self.frames = target.frames.map do |f|
          f = f.call(eyes.driver) if f.is_a?(Proc)
          normalize_element_selector(f)
        end
      end

      self.fully = target.options[:stitch_content]
      self.hooks = target.options[:script_hooks]

      # require('pry')
      # binding.pry

      self.ignore_regions = target.ignored_regions.map do |ir|
        ir.is_a?(Proc) ? normalize_element_selector(ir.call(eyes.driver)) : ir
      end
      # self.ignore_regions = target.ignored_regions
      self.layout_regions = target.layout_regions.map do |lr|
        lr.is_a?(Proc) ? normalize_element_selector(lr.call(eyes.driver)) : lr
      end

      if target.region_to_check.is_a?(Hash)
        self.region = target.region_to_check
      elsif target.region_to_check.is_a?(String)
        self.region = target.region_to_check
      elsif target.region_to_check.is_a?(Proc)
        # require('pry')
        # binding.pry
        el = target.region_to_check.call(eyes.driver)
        self.region = normalize_element_selector(el) unless el.respond_to?(:empty?) && el.empty?
      end
      # self.region = normalize_element_selector(target.region_to_check.call(eyes.driver))
      # self.region = nil if region.empty?

      self.strict_regions = target.strict_regions
      self.timeout = target.options[:timeout]
      self.variation_group_id = target.options[:variation_group_id]
      self.wait_before_capture = target.options[:wait_before_capture]
      self.lazy_load = target.options[:lazy_load]
      self.page_id = target.options[:page_id]

      self.scroll_root_element = target.options[:scroll_root_element] || eyes.scroll_root_element
      self.layout_breakpoints = target.options[:layout_breakpoints] || eyes.layout_breakpoints

      self.exact = (target.options[:exact] && target.options[:exact].to_hash) || (eyes.exact && eyes.exact.to_hash)
      self.enable_patterns = from_target_options_or_eyes(:enable_patterns, target.options, eyes)
      self.ignore_caret = from_target_options_or_eyes(:ignore_caret, target.options, eyes)
      self.ignore_displacements = from_target_options_or_eyes(:ignore_displacements, target.options, eyes)
      self.match_level = from_target_options_or_eyes(:match_level, target.options, eyes)
      self.send_dom = from_target_options_or_eyes(:send_dom, target.options, eyes)
      self.use_dom = from_target_options_or_eyes(:use_dom, target.options, eyes)
      self.visual_grid_options = from_target_options_or_eyes(:visual_grid_options, target.options, eyes)
      self.ufg_options = self.visual_grid_options
      self.user_command_id = self.variation_group_id

      self.image = target.image if target.respond_to?(:image)
    # rescue => e
    #   require('pry')
    #   binding.pry
    end

    def from_eyes_images(target, eyes)
      self.accessibility_settings = eyes.accessibility_validation
      self.disable_browser_fetching = eyes.dont_fetch_resources
      self.accessibility_regions = target.accessibility_regions
      self.floating_regions = target.floating_regions

      self.ignore_regions = target.ignored_regions.map do |ir|
        ir.is_a?(Proc) ? normalize_element_selector(ir.call(eyes.driver)) : ir
      end

      if target.region_to_check.is_a?(Hash)
        self.region = target.region_to_check
      elsif target.region_to_check.is_a?(String)
        self.region = target.region_to_check
      elsif target.region_to_check.is_a?(Proc)
        el = target.region_to_check.call(eyes.driver)
        self.region = normalize_element_selector(el) unless el.respond_to?(:empty?) && el.empty?
      end

      self.exact = (target.options[:exact] && target.options[:exact].to_hash) || (eyes.exact && eyes.exact.to_hash)

      self.image = target.image
    end

    def to_hash
      json_data.compact.reject do |_, v|
        case v
          when Array, Hash
            v.empty?
          when Numeric
            v.zero?
          # when FalseClass
          #   true
          else
            false
        end
      end
    end

    private

    def from_target_options_or_eyes(what, options, eyes)
      return options[what] unless options[what].nil?
      return eyes.send(what) if eyes.respond_to?(what)
      nil
    end

  end
end
# U-Notes : Added internal Applitools::UniversalCheckSettings
