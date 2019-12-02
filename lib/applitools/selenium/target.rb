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
        :floating_regions, :frame_or_element, :regions, :match_level, :layout_regions, :content_regions,
        :strict_regions, :accessibility_regions

      private :frame_or_element, :frame_or_element=

      # Initialize a Applitools::Selenium::Target instance.
      def initialize
        self.frames = []
        self.options = {
          ignore_caret: true,
          ignore_mismatch: false,
          send_dom: nil,
          script_hooks: { beforeCaptureScreenshot: '' }
        }
        self.regions = {}
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
          requested_padding = if args.last.is_a? Applitools::PaddingBounds
                                args.pop
                              else
                                Applitools::PaddingBounds::PIXEL_PADDING
                              end
          ignored_regions << case args.first
                             when Applitools::Region
                               proc { args.first.padding(requested_padding) }
                             when ::Selenium::WebDriver::Element
                               proc do |driver, return_element = false|
                                 region = applitools_element_from_selenium_element(driver, args.first)
                                 padding_proc = proc do |reg|
                                   Applitools::Region.from_location_size(
                                     reg.location, reg.size
                                   ).padding(requested_padding)
                                 end
                                 next region, padding_proc if return_element
                                 padding_proc.call(region)
                               end
                             when Applitools::Selenium::Element
                               proc do |_driver, return_element = false|
                                 region = args.first
                                 padding_proc = proc do |reg|
                                   Applitools::Region.from_location_size(
                                     reg.location, reg.size
                                   ).padding(requested_padding)
                                 end
                                 next region, padding_proc if return_element
                                 padding_proc.call(region)
                               end
                             else
                               proc do |driver, return_element = false|
                                 region = driver.find_element(*args)
                                 padding_proc = proc do |reg|
                                   Applitools::Region.from_location_size(
                                     reg.location, reg.size
                                   ).padding(requested_padding)
                                 end
                                 next region, padding_proc if return_element
                                 padding_proc.call(region)
                               end
                             end

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
        requested_padding = if args.last.is_a? Applitools::PaddingBounds
                              args.pop
                            else
                              Applitools::PaddingBounds::PIXEL_PADDING
                            end
        value = case args.first
                when Applitools::FloatingRegion
                  args.first.padding(requested_padding)
                when ::Applitools::Region
                  Applitools::FloatingRegion.any(args.shift, *args).padding(requested_padding)
                when ::Selenium::WebDriver::Element
                  proc do |driver, return_element = false|
                    args_dup = args.dup
                    region = applitools_element_from_selenium_element(driver, args_dup.shift)
                    padding_proc = proc do |reg|
                      Applitools::FloatingRegion.any(reg, *args_dup).padding(requested_padding)
                    end
                    next region, padding_proc if return_element
                    padding_proc.call(region)
                  end
                when ::Applitools::Selenium::Element
                  proc do |_driver, return_element = false|
                    args_dup = args.dup
                    region = args_dup.shift
                    padding_proc = proc do |reg|
                      Applitools::FloatingRegion.any(reg, *args_dup).padding(requested_padding)
                    end
                    next region, padding_proc if return_element
                    padding_proc.call(region)
                  end
                else
                  proc do |driver, return_element = false|
                    args_dup = args.dup
                    region = driver.find_element(args_dup.shift, args_dup.shift)
                    padding_proc = proc do |reg|
                      Applitools::FloatingRegion.any(
                        reg, *args_dup
                      ).padding(requested_padding)
                    end
                    next region, padding_proc if return_element
                    padding_proc.call(region)
                  end
                end
        floating_regions << value
        self
      end

      def layout(*args)
        return match_level(Applitools::MatchLevel::LAYOUT) if args.empty?
        region = process_region(*args)
        layout_regions << region
        self
      end

      def content(*args)
        return match_level(Applitools::MatchLevel::CONTENT) if args.empty?
        region = process_region(*args)
        content_regions << region
        self
      end

      def strict(*args)
        return match_level(Applitools::MatchLevel::STRICT) if args.empty?
        region = process_region(*args)
        strict_regions << region
        self
      end

      def exact(*args)
        match_level(Applitools::MatchLevel::EXACT, *args)
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

      def match_level(*args)
        match_level = args.shift
        exact_options = args.shift || {}
        (options[:match_level], options[:exact]) = match_level_with_exact(match_level, exact_options)
        self
      end

      def fully(value = true)
        options[:stitch_content] = value ? true : false
        handle_frames
        self
      end

      def frame(element)
        frames << frame_or_element if frame_or_element
        self.frame_or_element = element
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
        handle_frames
        self.region_to_check = case args.first
                               when ::Selenium::WebDriver::Element
                                 proc do |driver|
                                   applitools_element_from_selenium_element(driver, args.first)
                                 end
                               when Applitools::Selenium::Element, Applitools::Region
                                 proc { args.first }
                               when String
                                 proc do |driver|
                                   driver.find_element(name_or_id: args.first)
                                 end
                               else
                                 proc do |driver|
                                   driver.find_element(*args)
                                 end
                               end
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

      def script_hook(hook)
        options[:script_hooks][:beforeCaptureScreenshot] = hook
        self
      end

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
            'You should call Target.accessibility(region, region_type: type). The region_type option is required'
        end
        unless Applitools::AccessibilityRegionType.enum_values.include?(options[:type])
          raise Applitools::EyesIllegalArgument,
            "The region type should be one of [#{Applitools::AccessibilityRegionType.enum_values.join(', ')}]"
        end
        handle_frames
        padding_proc = proc do |region|
          Applitools::AccessibilityRegion.new(
            region, options[:type]
          )
        end

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
        if options[:stitch_content].nil?
          case region_to_check
          when nil
            fully(true)
          when Proc
            begin
              r = region_to_check.call
              fully(true) if r == Applitools::Region::EMPTY
            rescue StandardError
              fully(false)
            end
          end
        end
        nil
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
    end
  end
end
