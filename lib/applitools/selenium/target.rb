require 'applitools/core/floating_region'

module Applitools
  module Selenium
    class Target
      # include Applitools::FluentInterface
      # include Applitools::MatchLevelSetter
      class << self
        def frame(element)
          new.frame(element)
        end

        def window
          new # .fully
        end

        def region(*args) # (by, what = nil)
          new.region(*args) #(by, what)
        end
      end


      def initialize
        @target = {}
      end

      def frame(input)
        @target[:frames] = [] if !@target[:frames]
        if input.is_a?(Hash) && input[:css]
          @target[:frames] << { type: 'css', selector: input[:css] }
        else
          @target[:frames] << input
        end
        self
      end

      def region(by, what = nil)
        by = 'class name' if by === :class_name
        by = '-ios predicate string' if by === :predicate # IOS_PREDICATE: '-ios predicate string',
        # by = '-ios class chain' if by === # IOS_CLASS_CHAIN: '-ios class chain',

        if (!what && by.is_a?(::Applitools::Region))
          @target[:region] = by.to_socket_output
        elsif (!what && by.is_a?(::Selenium::WebDriver::Element))
          @target[:region] = by
          # rect = by.rect # or use eyes magic with set_element_selector_proc
          # @target[:region] = ::Applitools::Region.new(rect.x, rect.y, rect.width, rect.height).to_socket_output
        elsif by.is_a?(Hash) && by['selector']
          @target[:region] = by['shadow'] ? {:selector => by['selector'], :shadow => by['shadow']} : {:selector => by['selector']}
        elsif by === :accessibility_id
          @target[:region] = {:type => 'accessibility id', :selector => what}
        else
          @target[:region] = {:type => by.to_s, :selector => what}
        end
        self
      end

      def fully(toggle = true)
        @target[:fully] = toggle
        self
      end

      def scroll_root_element(by, what = nil)
        if what
          @target[:scrollRootElement] = { type: by.to_s, selector: what }
        else
          @target[:scrollRootElement] = by
        end
        self
      end

      def ignore(by, what = nil)
        by = '-android uiautomator' if by === :uiautomator # ANDROID_UI_AUTOMATOR: '-android uiautomator'
        by = '-ios predicate string' if by === :predicate # IOS_PREDICATE: '-ios predicate string',
        @target[:ignoreRegions] = [] if !@target[:ignoreRegions]
        if (!what && by.is_a?(::Applitools::Region))
          @target[:ignoreRegions] << by.to_socket_output
        elsif by === :accessibility_id
          @target[:ignoreRegions] << {:type => 'accessibility id', :selector => what}
        else
          @target[:ignoreRegions] << {type: by.to_s, selector: what}
        end
        self
      end

      def accessibility(*args) # (:css, '.ignore', type: 'LargeText') -> accessibilityRegions
        # ToDo : ...
        region = { region: args[1], type: args[2][:type] }
        @target[:accessibilityRegions] = [region]
        self
      end


      def ignore_displacements(toggle)
        @target[:ignoreDisplacements] = toggle
        self
      end


      def window
        fully
        self
      end

      def send_dom(value = true)
        @target[:sendDom] = value ? true : false
        self
      end

      def layout_breakpoints(value = true)
        @target[:layoutBreakpoints] = value.is_a?(Array) ? value : value
        self
      end

      attr_accessor :floating_regions, :accessibility_regions
      def floating(*args)
        floating = args.last.is_a?(Applitools::FloatingBounds) ? args.last.to_socket_output : {}

        if args.first === :css
          region = { region: { type: :css, selector: args[1] } }
        elsif args.first.is_a?(Applitools::Region)
          region = { region: args.first.to_socket_output }
        end

        value = region.merge(floating)
        floating_regions ||= []
        floating_regions << value
        @target[:floatingRegions] = floating_regions
        self
      end

      def visual_grid_options(value)
        Applitools::ArgumentGuard.hash(value, 'value')
        @target[:visualGridOptions] = value
        self
      end

      def variation_group_id(value)
        Applitools::ArgumentGuard.not_nil(value, 'variation_group_id')
        @target[:variationGroupId] = value
        self
      end

      def hooks(hooks)
        @target[:hooks] = hooks[:beforeCaptureScreenshot] if hooks[:beforeCaptureScreenshot]
        self
      end

      def timeout(value)
        @target[:timeout] = value.to_i
        self
      end


      def to_socket_output
        @target.to_h
      end

    end
  end
end
