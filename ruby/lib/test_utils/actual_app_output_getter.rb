module Applitools
  module TestUtils
    class ActualAppOutputGetter
      def initialize(index = 0, &block)
        @get_app_output_block = block
        @app_output = nil
        @chain = []
        @index = index
      end

      def with_raw_output(&block)
        @chain.push proc { block.call(@app_output) }
        self
      end

      def with_image_match_settings(&block)
        @chain.push proc { block.call(image_match_settings) }
        self
      end

      def with_floating_regions(&block)
        @chain.push proc { block.call(floating_regions) }
      end

      def with_ignore_regions(&block)
        @chain.push proc { block.call(ignore_regions) }
      end

      def with_accessibility_regions(&block)
        @chain.push proc { block.call(accessibility_regions) }
      end

      def perform
        @app_output = @get_app_output_block.call
        @chain.map { |b| b.call }
      end

      private

      def floating_regions
        @actual_floating ||= image_match_settings['floating'].map do |r|
          Applitools::FloatingRegion.new(
            r['left'], r['top'], r['width'], r['height'],
            r['maxLeftOffset'], r['maxUpOffset'], r['maxRightOffset'], r['maxDownOffset']
          )
        end
      end

      def ignore_regions
        @actual_ignore ||= image_match_settings['ignore'].map do |r|
          Applitools::Region.new(r['left'], r['top'], r['width'], r['height'])
        end

      end

      def accessibility_regions
        @actual_accessibility ||= image_match_settings['accessibility'].map do |r|
          Applitools::AccessibilityRegion.new(
            Applitools::Region.new(r['left'], r['top'], r['width'], r['height']),
            r['type']
          )
        end
      end

      def image_match_settings
        @app_output['actualAppOutput'][@index]['imageMatchSettings']
      end
    end
  end
end