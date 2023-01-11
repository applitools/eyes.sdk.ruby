# frozen_string_literal: true

module Applitools
  module Selenium
    class RegionProvider
      FF_OLD_VERSION = '45.0'

      attr_accessor :driver, :eye_region, :scroll_position_provider

      def initialize(driver, eye_region)
        self.driver = driver
        self.eye_region = eye_region
        self.scroll_position_provider = Applitools::Selenium::ScrollPositionProvider.new driver
      end

      def region(include_borders = true)
        region = if include_borders
                   location = eye_region.location.offset_negative(
                     Applitools::Location.new(eye_region.padding_left, eye_region.padding_top)
                   )
                   size = eye_region.size.tap do |s|
                     s.width += eye_region.padding_left + eye_region.padding_right
                     s.height += eye_region.padding_top + eye_region.padding_bottom
                   end
                   Applitools::Region.from_location_size(location, size)
                 else
                   Applitools::Region.from_location_size(eye_region.location, eye_region.size)
                 end
        if inside_a_frame?
          frame_window = calculate_frame_window
          return frame_window if eye_region.is_a?(Applitools::Region) && eye_region.empty?
          region.location = region.location.offset(frame_window.location)
          region.intersect(frame_window) unless frame_window.empty?
          # exception if empty
        else
          region.location = region.location.offset_negative scroll_position_provider.current_position
        end
        return eye_region if eye_region.is_a?(Applitools::Region) && eye_region.empty?
        region
      end

      def coordinate_type
        nil
      end

      def calculate_frame_window
        return Applitools::Region::EMPTY unless inside_a_frame?
        frame_window_calculator.frame_window(driver.frame_chain)
      end

      private

      def inside_a_frame?
        !driver.frame_chain.empty?
      end

      def frame_window_calculator
        return FirefoxFrameWindowCalculator if
            driver.browser.running_browser_name == :firefox &&
                (Gem::Version.new(driver.capabilities.version) <=> Gem::Version.new(FF_OLD_VERSION)) > 0
        FrameWindowCalculator
      end

      module FrameWindowCalculator
        extend self
        def frame_window(frame_chain)
          chain = Applitools::Selenium::FrameChain.new other: frame_chain
          window = nil
          frames_offset = Applitools::Location.new(0, 0)
          chain.map(&:dup).each do |frame|
            frames_offset = frame.location.offset(frames_offset).offset_negative(frame.parent_scroll_position)
            if window.nil?
              window = Applitools::Region.from_location_size(frame.location, frame.size)
            else
              window.intersect(Applitools::Region.from_location_size(frame.location, frame.size))
            end
            # exception if empty window
          end
          window
        end
      end

      module FirefoxFrameWindowCalculator
        extend self
        def frame_window(_frame_chain)
          Applitools::Region::EMPTY
        end
      end
    end
  end
end
