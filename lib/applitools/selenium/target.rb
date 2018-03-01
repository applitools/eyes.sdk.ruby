# frozen_string_literal: true

module Applitools
  module Selenium
    class Target
      include Applitools::FluentInterface
      class << self
        def frame(element)
          new.frame(element)
        end

        def window
          new
        end

        def region(element)
          new.region(element)
        end
      end

      attr_accessor :element, :frames, :region_to_check, :coordinate_type, :options, :ignored_regions, :floating_regions

      # Initialize a Applitools::Selenium::Target instance.
      def initialize
        self.frames = []
        self.options = {
          ignore_caret: false,
          ignore_mismatch: false
        }
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
                             when Applitools::Selenium::Element, ::Selenium::WebDriver::Element
                               proc do
                                 region = args.first
                                 Applitools::Region.from_location_size(
                                   region.location, region.size
                                 ).padding(requested_padding)
                               end
                             else
                               proc do |driver|
                                 region = driver.find_element(*args)
                                 Applitools::Region.from_location_size(
                                   region.location, region.size
                                 ).padding(requested_padding)
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
                  proc { args.first.padding(requested_padding) }
                when ::Selenium::WebDriver::Element, Applitools::Selenium::Element, ::Applitools::Region
                  proc { Applitools::FloatingRegion.any(args.shift, *args).padding(requested_padding) }
                else
                  proc do |driver|
                    Applitools::FloatingRegion.any(
                      driver.find_element(args.shift, args.shift), *args
                    ).padding(requested_padding)
                  end
                end
        floating_regions << value
        self
      end

      def fully
        options[:stitch_content] = true
        self
      end

      def frame(element)
        frames << element
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
        self.region_to_check = case args.first
                               when Applitools::Selenium::Element, Applitools::Region, ::Selenium::WebDriver::Element
                                 proc { args.first }
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

      private

      def reset_for_fullscreen
        self.coordinate_type = nil
        self.region_to_check = proc { Applitools::Region::EMPTY }
        reset_ignore
        reset_floating
        options[:stitch_content] = false
        options[:timeout] = nil
        options[:trim] = false
      end

      def reset_ignore
        self.ignored_regions = []
      end

      def reset_floating
        self.floating_regions = []
      end
    end
  end
end
