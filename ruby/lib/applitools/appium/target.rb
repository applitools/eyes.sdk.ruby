# frozen_string_literal: true

module Applitools
  module Appium
    class Target < Applitools::Selenium::Target

      def ignore(*args)
        if args.empty?
          reset_ignore
        else
          value = convert_to_universal(args)
          value = { type: args[0], selector: args[1] } if value.nil?
          # value = value[:selector] if value.is_a?(Hash) && (value[:type].to_s === 'id') && !is_a?(Applitools::Appium::Target)
          ignored_regions << value
        end
        self
      end

      def region(*args)
        value = convert_to_universal(args)
        value = { type: args[0], selector: args[1] } if value.nil?
        # value = value[:selector] if value.is_a?(Hash) && (value[:type].to_s === 'id') && !is_a?(Applitools::Appium::Target)
        self.region_to_check = value
        self.coordinate_type = Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative]
        options[:timeout] = nil
        reset_ignore
        reset_floating
        self
      end
    # class Target
    #   include Applitools::FluentInterface
    #   attr_accessor :region_to_check, :options, :ignored_regions, :floating_regions, :layout_regions, :content_regions, :strict_regions, :accessibility_regions
    #
    #   class << self
    #     def window
    #       new
    #     end
    #
    #     def region(*args)
    #       new.region(*args)
    #     end
    #   end
    #
    #   def initialize
    #     self.region_to_check = proc { Applitools::Region::EMPTY }
    #     self.ignored_regions = []
    #     self.floating_regions = []
    #     self.layout_regions = []
    #     self.content_regions = []
    #     self.strict_regions = []
    #     self.accessibility_regions = []
    #     self.options = {}
    #   end
    #
    #   def region(*args)
    #     self.region_to_check = case args.first
    #                            when ::Selenium::WebDriver::Element
    #                              proc { args.first }
    #                            else
    #                              proc do |driver|
    #                                driver.find_element(*args)
    #                              end
    #                            end
    #     self
    #   end
    #
    #   def ignore(*args)
    #     requested_padding = if args.last.is_a? Applitools::PaddingBounds
    #                           args.pop
    #                         else
    #                           Applitools::PaddingBounds::ZERO_PADDING
    #                         end
    #     ignored_regions <<  case (first_argument = args.first)
    #                         when ::Selenium::WebDriver::Element
    #                           proc do
    #                             Applitools::Region
    #                               .from_location_size(first_argument.location, first_argument.size)
    #                               .padding(requested_padding)
    #                           end
    #                         when Applitools::Region
    #                           result = first_argument.padding(requested_padding)
    #                           if Applitools::Appium::Utils.ios?(Applitools::Appium::Driver::AppiumLib)
    #                             def result.converted?
    #                               true
    #                             end
    #                           end
    #                           result
    #                         else
    #                           proc do |driver|
    #                             element = driver.find_element(*args)
    #                             Applitools::Region
    #                               .from_location_size(element.location, element.size)
    #                               .padding(requested_padding)
    #                           end
    #                         end
    #     self
    #   end
    #
    #   def floating(*args)
    #     value = case args.first
    #             when Applitools::FloatingRegion
    #               args.first
    #             when Applitools::Region
    #               result = Applitools::FloatingRegion.any(*args)
    #               if Applitools::Appium::Utils.ios?(Applitools::Appium::Driver::AppiumLib)
    #                 def result.converted?
    #                   true
    #                 end
    #               end
    #               result
    #             when ::Selenium::WebDriver::Element
    #               args_dup = args.dup
    #               Applitools::FloatingRegion.any(*args_dup)
    #             else
    #               proc do |driver|
    #                 args_dup = args.dup
    #                 region = driver.find_element(args_dup.shift, args_dup.shift)
    #                 Applitools::FloatingRegion.any(
    #                     region, *args_dup
    #                 )
    #               end
    #             end
    #     floating_regions << value
    #     self
    #   end
    #
    #   def layout
    #     return match_level(Applitools::MatchLevel::LAYOUT) if args.empty?
    #     region = process_region(*args)
    #     layout_regions << region
    #   self
    #
    #   end
    #
    #   def content(*args)
    #     return match_level(Applitools::MatchLevel::CONTENT) if args.empty?
    #     region = process_region(*args)
    #     content_regions << region
    #     self
    #   end
    #
    #   def strict(*args)
    #     return match_level(Applitools::MatchLevel::STRICT) if args.empty?
    #     region = process_region(*args)
    #     strict_regions << region
    #     self
    #   end
    #
    #   def exact(*args)
    #     match_level(Applitools::MatchLevel::EXACT, *args)
    #   end
    #
    #   def accessibility(*args)
    #     options = Applitools::Utils.extract_options! args
    #     unless options[:type]
    #       raise Applitools::EyesError,
    #             'You should call Target.accessibility(region, type: type). The region_type option is required'
    #     end
    #     unless Applitools::AccessibilityRegionType.enum_values.include?(options[:type])
    #       raise Applitools::EyesIllegalArgument,
    #             "The region type should be one of [#{Applitools::AccessibilityRegionType.enum_values.join(', ')}]"
    #     end
    #
    #     accessibility_regions << case args.first
    #                              when ::Selenium::WebDriver::Element
    #                                element = args.first
    #                                Applitools::AccessibilityRegion.new(
    #                                  element,
    #                                  options[:type]
    #                                )
    #                              when Applitools::Region
    #                                result = Applitools::AccessibilityRegion.new(
    #                                    args.first, options[:type]
    #                                )
    #                                if Applitools::Appium::Utils.ios?(Applitools::Appium::Driver::AppiumLib)
    #                                  def result.converted?
    #                                    true
    #                                  end
    #                                end
    #                                result
    #                              when String
    #                                proc do |driver|
    #                                  element = driver.find_element(name_or_id: args.first)
    #                                  Applitools::AccessibilityRegion.new(
    #                                    element,
    #                                    options[:type]
    #                                  )
    #                                end
    #                              else
    #                                proc do |driver|
    #                                  elements = driver.find_elements(*args)
    #                                  elements.map do |e|
    #                                    Applitools::AccessibilityRegion.new(
    #                                      e,
    #                                      options[:type]
    #                                    )
    #                                  end
    #                                end
    #                              end
    #     self
    #   end
    #
    #   def finalize
    #     self
    #   end
    #
    #   private
    #
    #   def process_region(*args)
    #     r = args.first
    #     case r
    #     when ::Selenium::WebDriver::Element
    #       proc do |driver|
    #         Applitools::Region.from_location_size(r.location, r.size)
    #       end
    #     when Applitools::Region
    #       if Applitools::Appium::Utils.ios?(Applitools::Appium::Driver::AppiumLib)
    #         def r.converted?
    #           true
    #         end
    #       end
    #       r
    #     else
    #       proc do |driver|
    #         element = driver.find_element(*args)
    #         Applitools::Region.from_location_size(element.location, element.size)
    #       end
    #     end
    #   end
    #
    end
  end
end
