# frozen_string_literal: true

module Applitools::Images
  class Target
    include Applitools::FluentInterface
    class << self
      def path(path)
        raise Applitools::EyesIllegalArgument unless File.exist?(path)
        # new Applitools::Screenshot.from_image(ChunkyPNG::Image.from_file(path))
        new(path)
      end

      def blob(blob_image)
        Applitools::ArgumentGuard.not_nil blob_image, 'blob_image'
        Applitools::ArgumentGuard.is_a? blob_image, 'blob_image', String
        new(blob_image)
      end

      def image(image)
        Applitools::ArgumentGuard.not_nil image, 'image'
        # Applitools::ArgumentGuard.is_a? image, 'image', ChunkyPNG::Image
        new(image)
      end

      def screenshot(screenshot)
        Applitools::ArgumentGuard.not_nil screenshot, 'screenshot'
        Applitools::ArgumentGuard.is_a? screenshot, 'screenshot', Applitools::Screenshot
        new screenshot
      end

      def any(screenshot)
        new(screenshot)
      end
    end

    attr_accessor :image, :options, :ignored_regions, :region_to_check, :floating_regions, :accessibility_regions

    def convert_image_arg(image_arg)
      if image_arg.is_a?(Applitools::Screenshot)
        Base64.strict_encode64(image_arg.to_blob).force_encoding('UTF-8')
      elsif image_arg.class.name === 'ChunkyPNG::Image'
        Base64.strict_encode64(image_arg.to_blob).force_encoding('UTF-8')
      elsif image_arg.is_a?(Hash) && !image_arg[:image_path].nil?
        image_arg[:image_path]
      elsif image_arg.is_a?(Hash) && !image_arg[:image].nil?
        Base64.strict_encode64(image_arg[:image]).force_encoding('UTF-8')
      elsif image_arg.is_a?(Hash)
        raise Applitools::EyesIllegalArgument.new "Image is unrecognized, try  to use image_path: path_or_url or image: buffer"
      elsif image_arg.is_a?(String) && File.exist?(image_arg) # Path
        image_arg
      elsif image_arg.is_a?(String) # URL ? Buffer
        raise Applitools::EyesIllegalArgument.new "Passed image is not explicit, try  to use image_path: path_or_url or image: buffer"
      else
        raise Applitools::EyesIllegalArgument.new "Passed image is unrecognized"
      end
    end

    def initialize(image_arg)
      image = convert_image_arg(image_arg)
      Applitools::ArgumentGuard.not_nil(image, 'image')
      Applitools::ArgumentGuard.is_a? image, 'image', String
      self.image = image
      self.ignored_regions = []
      self.floating_regions = []
      self.accessibility_regions = []
      self.options = {
        trim: false
      }
    end

    def ignore(*args)
      region = region_from_args(args)
      ignored_regions << region if region
      self
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

    def region(region = nil)
      if region
        Applitools::ArgumentGuard.is_a? region, 'region', Applitools::Region
        self.region_to_check = region.to_hash
      else
        self.region_to_check = nil
      end
      self
    end

    def accesibility(*args)
      accessibility_regions << case args.first
                               when Applitools::AccessibilityRegion
                                 args.first
                               when Applitools::Region
                                 Applitools::AccessibilityRegion.new(args.first, args.last)
                               else
                                 accessibility_region_type = args.pop
                                 region = Applitools::Region.new(*args)
                                 Applitools::AccessibilityRegion.new(region, accessibility_region_type)
                               end
    end



    private # dupl

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
