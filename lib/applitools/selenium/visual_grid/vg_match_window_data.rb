# frozen_string_literal: true

module Applitools
  module Selenium
    class VgMatchWindowData < Applitools::MatchWindowData
      class RegionCoordinatesError < ::Applitools::EyesError
        attr_accessor :region
        def initialize(region, message)
          super(message)
          self.region = region
        end
      end
      attr_accessor :target, :selector_regions
      def read_target(target, driver, selector_regions)
        self.target = target
        self.selector_regions = selector_regions
        # options
        target_options_to_read.each do |field|
          a_value = target.options[field.to_sym]
          send("#{field}=", a_value) unless a_value.nil?
        end
        # ignored regions
        if target.respond_to? :ignored_regions
          target.ignored_regions.each do |r|
            @need_convert_ignored_regions_coordinates = true unless @need_convert_ignored_regions_coordinates
            case r
            when Proc
              region, padding_proc = r.call(driver, true)
              region = selector_regions[target.regions[region]]
              retrieved_region = Applitools::Region.new(region['x'], region['y'], region['width'], region['height'])
              @ignored_regions << padding_proc.call(retrieved_region) if padding_proc.is_a? Proc
            when Applitools::Region
              @ignored_regions << r
            when Applitools::Selenium::VGRegion
              region = target.regions.key?(r.region) ? selector_regions[target.regions[r.region]] : r.region
              raise RegionCoordinatesError.new(r, region['error']) if region['error']
              retrieved_region = Applitools::Region.new(region['x'], region['y'], region['width'], region['height'])
              @ignored_regions << if r.padding_proc.is_a?(Proc)
                                    r.padding_proc.call(retrieved_region)
                                  else
                                    retrieved_region
                                  end
            end
          end
        end

        if target.respond_to? :layout_regions
          @layout_regions = obtain_regions_coordinates(target.layout_regions, driver)
          @need_convert_layout_regions_coordinates = true unless @layout_regions.empty?
        end

        if target.respond_to? :content_regions
          @content_regions = obtain_regions_coordinates(target.content_regions, driver)
          @need_convert_content_regions_coordinates = true unless @content_regions.empty?
        end

        if target.respond_to? :strict_regions
          @strict_regions = obtain_regions_coordinates(target.strict_regions, driver)
          @need_convert_strict_regions_coordinates = true unless @strict_regions.empty?
        end

        if target.respond_to? :accessibility_regions
          @accessibility_regions = obtain_regions_coordinates(target.accessibility_regions, driver)
          @need_convert_accessibility_regions_coordinates = true unless @accessibility_regions.empty?
        end

        # # floating regions
        return unless target.respond_to? :floating_regions
        target.floating_regions.each do |r|
          case r
          when Proc
            region, padding_proc = r.call(driver, true)
            region = selector_regions[target.regions[region]]
            retrieved_region = Applitools::Region.new(region['x'], region['y'], region['width'], region['height'])
            floating_region = padding_proc.call(retrieved_region) if padding_proc.is_a? Proc
            raise Applitools::EyesError.new "Wrong floating region: #{region.class}" unless
                floating_region.is_a? Applitools::FloatingRegion
            @floating_regions << floating_region
            @need_convert_floating_regions_coordinates = true
          when Applitools::FloatingRegion
            @floating_regions << r
            @need_convert_floating_regions_coordinates = true
          when Applitools::Selenium::VGRegion
            region = r.region
            region = selector_regions[target.regions[region]]
            raise RegionCoordinatesError.new(r, region['error']) if region['error']
            retrieved_region = Applitools::Region.new(region['x'], region['y'], region['width'], region['height'])
            floating_region = r.padding_proc.call(retrieved_region) if r.padding_proc.is_a? Proc
            raise Applitools::EyesError.new "Wrong floating region: #{region.class}" unless
                floating_region.is_a? Applitools::FloatingRegion
            @floating_regions << floating_region
            @need_convert_floating_regions_coordinates = true
          end
        end
      end

      def obtain_regions_coordinates(regions, driver)
        result = []
        regions.each do |r|
          case r
          when Proc
            region = r.call(driver)
            region = selector_regions[target.regions[region]]
            result << Applitools::Region.new(region['x'], region['y'], region['width'], region['height'])
          when Applitools::Region
            result << r
          when Applitools::Selenium::VGRegion
            region = r.region
            region = selector_regions[target.regions[region]]
            raise RegionCoordinatesError.new(r, region['error']) if region['error']
            retrieved_region = Applitools::Region.new(region['x'], region['y'], region['width'], region['height'])
            result_region = r.padding_proc.call(retrieved_region) if r.padding_proc.is_a? Proc
            result << result_region
          end
        end
        result
      end

      def convert_ignored_regions_coordinates
        return unless @need_convert_ignored_regions_coordinates
        self.ignored_regions = @ignored_regions.map(&:with_padding).map(&:to_hash)
        @need_convert_ignored_regions_coordinates = false
      end

      def convert_floating_regions_coordinates
        return unless @need_convert_floating_regions_coordinates
        self.floating_regions = @floating_regions
        @need_convert_floating_regions_coordinates = false
      end

      def convert_layout_regions_coordinates
        return unless @need_convert_layout_regions_coordinates
        self.layout_regions = @layout_regions
        @need_convert_layout_regions_coordinates = false
      end

      def convert_strict_regions_coordinates
        return unless @need_convert_strict_regions_coordinates
        self.strict_regions = @strict_regions
        @need_convert_strict_regions_coordinates = false
      end

      def convert_content_regions_coordinates
        return unless @need_convert_content_regions_coordinates
        self.content_regions = @content_regions
        @need_convert_content_regions_coordinates = false
      end

      def convert_accessibility_regions_coordinates
        return unless @need_convert_accessibility_regions_coordinates
        self.accessibility_regions = @accessibility_regions
        @need_convert_accessibility_regions_coordinates = false
      end
    end
  end
end
