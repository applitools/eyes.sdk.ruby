# frozen_string_literal: true

module Applitools
  module Selenium
    class Target
      include Applitools::FluentInterface
      include Applitools::MatchLevelSetter
      class << self
        def frame(element)
          new.frame(element)
        end

        def window
          new
        end

        def region(*args)
          new.region(*args)
        end
      end

      attr_accessor :element, :frames, :region_to_check, :coordinate_type, :options, :ignored_regions,
        :floating_regions, :frame_or_element, :regions, :layout_regions, :content_regions,
        :strict_regions, :accessibility_regions, :convert_coordinates_block

      private :frame_or_element, :frame_or_element=

      # Initialize a Applitools::Selenium::Target instance.
      def initialize
        self.frames = []
        self.options = {
          ignore_mismatch: false,
          script_hooks: { beforeCaptureScreenshot: '' },
          visual_grid_options: {}
        }
        self.regions = {}
        self.convert_coordinates_block = nil
        reset_for_fullscreen
      end

      # Add the wanted ignored regions.
      #
      # @param [Applitools::Selenium::Element, Applitools::Region, ::Selenium::WebDriver::Element] region_or_element the region to ignore or an element representing the region to ignore
      # @param [Symbol, String] how A finder to be used (see Selenium::WebDriver documentation for complete list of available finders)
      # @param [Symbol, String] what An id or selector to find
      # @!parse def ignore(region_or_element, how, what, padding = Applitools::PaddingBounds::PIXEL_PADDING); end;

      def ignore(*args)
        if args.empty?
          reset_ignore
        else
          region = region_from_args(args)
          ignored_regions << region if region
        end
        self
      end

      # Sets the wanted floating region
      # @param region_or_element [Applitools::FloatingRegion, Selenium::WebDriver::Element, Applitools::Selenium::Element, Applitools::Region]
      # @param bounds [Applitools::FloatingBounds]
      # @!parse def floating(region_or_element, bounds, padding); end;
      # @param left [Integer]
      # @param top [Integer]
      # @param right [Integer]
      # @param bottom [Integer]
      # @param padding [Applitools::PaddingBounds]
      # @example
      #   target.floating(:id, 'my_id', 10, 10, 10, 10)
      # @example
      #   target.floating(:id, 'my_id', Applitools::FloatingBounds.new(10, 10, 10, 10))
      # @example
      #   target.floating(region, Applitools::FloatingBounds.new(10, 10, 10, 10))
      # @example
      #   target.floating(floating_region)
      # @example
      #   target.floating(floating_region, bounds)
      # @example
      #   target.floating(:id, 'my_id', Applitools::FloatingBounds.new(10, 10, 10, 10), Applitools::PaddingBounds.new(10, 10, 10, 10))
      # @!parse def floating(region_or_element, bounds, left,top, right, bottom, padding); end;

      def floating(*args)
        options = Applitools::Utils.extract_options!(args)
        padding = options && options[:padding]
        requested_padding = get_requested_padding(padding, args)
        bounds = get_bounds(args)
        value = convert_to_universal(args)
        value = { type: args[0], selector: args[1] } if value.nil?
        value = value[:selector] if value.is_a?(Hash) && (value[:type].to_s === 'id')
        region = { region: value }
        region.merge!(bounds) if bounds != {}
        region.merge!(padding: requested_padding) if requested_padding != {}
        region.merge!(regionId: options[:region_id]) if options[:region_id]
        floating_regions << region
        self
      end

      def layout(*args)
        region = region_from_args(args)
        layout_regions << region if region
        self
      end

      def content(*args)
        region = region_from_args(args)
        content_regions << region if region
        self
      end

      def strict(*args)
        region = region_from_args(args)
        strict_regions << region if region
        self
      end

      def exact(*args)
        match_level(Applitools::MatchLevel::EXACT, *args)
      end

      def visual_grid_options(value)
        Applitools::ArgumentGuard.hash(value, 'value')
        options[:visual_grid_options] = value
        self
      end

      def process_region(*args)
        r = args.first
        case r
        when ::Selenium::WebDriver::Element
          proc do |driver|
            applitools_element_from_selenium_element(driver, args.dup.first)
          end
        when Applitools::Region, Applitools::Selenium::Element
          proc { r }
        else
          proc do |driver|
            args_dup = args.dup
            driver.find_element(args_dup.shift, args_dup.shift)
          end
        end
      end

      def replace_region(original_region, new_region, key)
        case key
        when :content_regions
          replace_element(original_region, new_region, content_regions)
        when :strict_regions
          replace_element(original_region, new_region, strict_regions)
        when :layout_regions
          replace_element(original_region, new_region, layout_regions)
        when :floating
          replace_element(original_region, new_region, floating_regions)
        when :ignore
          replace_element(original_region, new_region, ignored_regions)
        when :accessibility_regions
          replace_element(original_region, new_region, accessibility_regions)
        end
      end

      def replace_element(original, new, array)
        case new
        when Array
          index = array.index(original)
          array.delete_at(index)
          array.insert(index, *new)
        when Applitools::Selenium::VGRegion
          array[array.index(original)] = new
        end
      end

      def fully(value = true)
        options[:stitch_content] = value ? true : false
        handle_frames
        self
      end

      def variation_group_id(value)
        Applitools::ArgumentGuard.not_nil(value, 'variation_group_id')
        options[:variation_group_id] = value
        self
      end

      def frame(*args)
        element = case args.first
                  when ::Selenium::WebDriver::Element, Applitools::Selenium::Element, String
                    args.first
                  else
                    proc { |d| d.find_element(*args) }
                  end
        frames << element
        # frames << frame_or_element if frame_or_element
        # self.frame_or_element = element
        reset_for_fullscreen
        self
      end

      # Add the desired region.
      # @param [Applitools::Selenium::Element, Applitools::Region, ::Selenium::WebDriver::Element] element the target region or an element representing the target region
      # @param [Symbol, String] how The finder to be used (:css, :id, etc. see Selenium::WebDriver documentation for complete list of available finders)
      # @param [Symbol, String] what Selector or id of an element
      # @example Add region by element
      #   target.region(an_element)
      # @example Add target region by finder
      #   target.region(:id, 'target_region')
      # @return [Applitools::Selenium::Target] A Target instance.
      # @!parse def region(element, how, what); end;

      def region(*args)
        value = convert_to_universal(args)
        value = { type: args[0], selector: args[1] } if value.nil?
        value = value[:selector] if value.is_a?(Hash) && (value[:type].to_s === 'id')
        self.region_to_check = value
        self.coordinate_type = Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative]
        options[:timeout] = nil
        reset_ignore
        reset_floating
        self
      end

      def send_dom(value = true)
        options[:send_dom] = value ? true : false
        self
      end

      def use_dom(value = true)
        options[:use_dom] = value ? true : false
        self
      end

      def before_render_screenshot_hook(hook)
        if hook.is_a?(Hash) && hook[:beforeCaptureScreenshot]
          options[:script_hooks] = hook
        else
          options[:script_hooks][:beforeCaptureScreenshot] = hook
        end
        self
      end

      alias script_hook before_render_screenshot_hook
      alias hooks before_render_screenshot_hook

      def finalize
        return self unless frame_or_element
        region = frame_or_element
        self.frame_or_element = nil
        dup.region(region)
      end

      def accessibility(*args)
        options = Applitools::Utils.extract_options! args
        unless options[:type]
          raise Applitools::EyesError,
            'You should call Target.accessibility(region, type: type). The :type option is required'
        end
        unless Applitools::AccessibilityRegionType.enum_values.include?(options[:type])
          raise Applitools::EyesIllegalArgument,
            "The region type should be one of [#{Applitools::AccessibilityRegionType.enum_values.join(', ')}]"
        end
        handle_frames
        padding_proc = proc { |region| Applitools::AccessibilityRegion.new(region, options[:type]) }

        accessibility_regions << case args.first
                                 when ::Selenium::WebDriver::Element
                                   proc do |driver, return_element = false|
                                     element = applitools_element_from_selenium_element(driver, args.first)
                                     next element, padding_proc if return_element
                                     padding_proc.call(element)
                                   end
                                 when Applitools::Selenium::Element
                                   proc do |_driver, return_element = false|
                                     next args.first, padding_proc if return_element
                                     padding_proc.call(args.first)
                                   end
                                 when Applitools::Region
                                   Applitools::AccessibilityRegion.new(
                                     args.first, options[:type]
                                   )
                                 when String
                                   proc do |driver, return_element = false|
                                     element = driver.find_element(name_or_id: args.first)
                                     next element, padding_proc if return_element
                                     padding_proc.call(element)
                                   end
          when :css
            # (:css, '.ignore', type: 'LargeText')
            { region: args[1], type: options[:type] }
                                 else
                                   proc do |driver, return_element = false|
                                     elements = driver.find_elements(*args)
                                     next elements, padding_proc if return_element
                                     elements.map { |e| padding_proc.call(e) }
                                   end

                                 end
        self
      end

      def default_full_page_for_vg
        # if options[:stitch_content].nil?
        #   case region_to_check
        #   when nil
        #     fully(true)
        #   when Proc
        #     begin
        #       r = region_to_check.call
        #       # fully(true) if r == Applitools::Region::EMPTY
        #     rescue StandardError
        #       fully(false)
        #     end
        #   end
        # end
        nil
      end

      def convert_coordinates(&block)
        self.convert_coordinates_block = block
      end

      def scroll_root_element(by, what = nil)
        options[:scroll_root_element] = if is_element?(by)
          ref = by.ref
          ref = by.ref[1] if ref.is_a?(Array) && ref[0] === :element
          { elementId: ref }
        elsif what
          { type: by.to_s, selector: what }
        else
          by
        end
        self
      end

      def layout_breakpoints(value = true)
        options[:layout_breakpoints] = value.is_a?(Array) ? value : value
        self
      end

      def wait_before_capture(value)
        Applitools::ArgumentGuard.not_nil(value, 'wait_before_capture')
        options[:wait_before_capture] = value
        self
      end

      def page_id(value)
        Applitools::ArgumentGuard.not_nil(value, 'page_id')
        options[:page_id] = value
        self
      end

      def lazy_load(*args) # scroll_length, waiting_time, max_amount_to_scroll
        options[:lazy_load] = args.is_a?(Hash) ? args : true
        self
      end

      private

      def reset_for_fullscreen
        self.coordinate_type = nil
        self.region_to_check = proc { Applitools::Region::EMPTY }
        reset_ignore
        reset_floating
        reset_content_regions
        reset_layout_regions
        reset_strict_regions
        reset_accessibility_regions
        options[:stitch_content] = nil
        options[:timeout] = nil
        options[:trim] = false
      end

      def reset_accessibility_regions
        self.accessibility_regions = []
      end

      def reset_ignore
        self.ignored_regions = []
      end

      def reset_floating
        self.floating_regions = []
      end

      def reset_layout_regions
        self.layout_regions = []
      end

      def reset_content_regions
        self.content_regions = []
      end

      def reset_strict_regions
        self.strict_regions = []
      end

      def handle_frames
        return unless frame_or_element
        frames << frame_or_element
        self.frame_or_element = nil
      end

      def applitools_element_from_selenium_element(driver, selenium_element)
        xpath = driver.execute_script(Applitools::Selenium::Scripts::GET_ELEMENT_XPATH_JS, selenium_element)
        driver.find_element(:xpath, xpath)
      end

      def get_requested_padding(padding, args)
        return padding.to_hash if padding && padding.is_a?(Applitools::PaddingBounds)
        return padding if padding && (padding.is_a?(Hash) || padding.is_a?(Numeric))
        if args.last.is_a? Applitools::PaddingBounds
          args.pop
        # elsif args.last.is_a?(Applitools::FloatingBounds)
        #   args.pop.to_hash
        else
          {}
        end
      end

      def get_bounds(args)
        return args.pop.to_hash if args.last.is_a?(Applitools::FloatingBounds)
        last4 = args.last(4)
        if last4.size === 4 && last4.all? { |e| e.is_a?(Numeric) }
          FloatingBounds.new(*last4).to_hash
        else
          {}
        end
      end

      def region_from_args(args)
        options = Applitools::Utils.extract_options!(args)
        padding = options && options[:padding]
        requested_padding = get_requested_padding(padding, args)
        value = convert_to_universal(args)
        value = { type: args[0], selector: args[1] } if value.nil?
        value = value[:selector] if value.is_a?(Hash) && (value[:type].to_s === 'id')
        return nil if value === {selector: nil, type: nil}
        region = { region: value }
        region.merge!(padding: requested_padding) if requested_padding != {}
        region.merge!(regionId: options[:region_id]) if options[:region_id]
        region
      end


      def is_element?(el)
        el.is_a?(::Selenium::WebDriver::Element) || (el.is_a?(Applitools::Selenium::Element) && el.respond_to?(:ref))
      end

      def is_region?(region)
        region.is_a?(Applitools::FloatingRegion) || region.is_a?(Applitools::Region) # || region.is_a?(Applitools::Selenium::Element)
      end

      def is_finder?(finders)
        return false unless finders.is_a?(Array)
        return false unless finders[1]
        return true if [:uiautomator, :predicate, :accessibility_id].include?(finders[0].to_sym)
        Applitools::Selenium::Driver::FINDERS.has_key?(finders[0].to_sym)
      end

      def convert_to_universal(args)
        if is_element?(args.first)
          ref = args.first.ref
          ref = args.first.ref[1] if ref.is_a?(Array) && ref[0] === :element
          return { elementId: ref }
        end
        return args.first.to_hash if is_region?(args.first)
        if is_finder?(args)
          if Applitools::Selenium::Driver::FINDERS.has_key?(args[0])
            selector = args[1]
            selector = "##{args[1]}" if args[0] === :id && !args[1].start_with?('#') && instance_of?(Applitools::Selenium::Target)
            return {type: Applitools::Selenium::Driver::FINDERS[args[0]], selector: selector}
          end
          case args[0]
            when :uiautomator # ANDROID_UI_AUTOMATOR: '-android uiautomator'
              return {type: '-android uiautomator', selector: args[1]}
            when :predicate # IOS_PREDICATE: '-ios predicate string',
              return {type: '-ios predicate string', selector: args[1]}
            when :accessibility_id
              return {type: 'accessibility id', selector: args[1]}
          end
        end
        if args.first.is_a?(String)
          return proc { |driver| driver.find_element(name_or_id: args.first) }
        end
        if args.first.is_a?(Hash) && args.first.has_key?('selector')
          if args.first.has_key?('shadow')
            return {selector: args.first['selector'], shadow: args.first['shadow']}
          else
            return {selector: args.first['selector']}
          end
        end
        nil
      end

    end
  end
end
