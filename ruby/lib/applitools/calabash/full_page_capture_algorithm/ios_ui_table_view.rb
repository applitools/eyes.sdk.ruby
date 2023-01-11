# frozen_string_literal: true

require_relative 'base'

module Applitools
  module Calabash
    module FullPageCaptureAlgorithm
      class IosUITableView < Base
        NSSIZE = /^.*: {(?<width>\d+), (?<height>\d+)}$/
        NEXT_REQUEST_DELAY = 0.5
        CROP_SHADOW_BOUNDS = 5

        def initialize(*args)
          super
          @entire_content = nil
          @stitched_image = nil
          @original_position = nil
          @entire_size = nil
          @eyes_window = nil
        end

        def get_stitched_region(scroll_to_top = true)
          create_entire_image
          store_original_position
          scroll_left_top if scroll_to_top

          scroll_it! do |position, cut_vertical, cut_horizontal|
            current_region = cutted_eyes_window(cut_vertical ? :top : :none)
            current_region = cutted_eyes_window(cut_horizontal ? :left : :none, current_region)

            current_position = updated_position(cut_vertical ? :top : :none, position.dup)
            current_position = updated_position(cut_horizontal ? :left : :none, current_position)

            put_it_on_canvas!(
              screenshot_provider.capture_screenshot.sub_screenshot(
                current_region,
                Applitools::Calabash::EyesCalabashScreenshot::DRIVER,
                false,
                false
              ).image.image,
              current_position.scale_it!(screenshot_provider.density)
            )
          end

          Applitools::Calabash::EyesCalabashIosScreenshot.new(
            Applitools::Screenshot.from_image(stitched_image),
            scale_factor: screenshot_provider.density
          )
        end

        def cutted_eyes_window(side, region = eyes_window)
          case side
          when :top
            Applitools::Region.new(
              region.left,
              region.top + CROP_SHADOW_BOUNDS,
              region.width,
              region.height - CROP_SHADOW_BOUNDS
            )
          when :left
            Applitools::Region.new(
              region.left + CROP_SHADOW_BOUNDS,
              region.top,
              region.width - CROP_SHADOW_BOUNDS,
              region.height
            )
          else
            region.dup
          end
        end

        def updated_position(side, position)
          case side
          when :top
            position.offset Applitools::Location.new(0, CROP_SHADOW_BOUNDS)
          when :left
            position.offset Applitools::Location.new(CROP_SHADOW_BOUNDS, 0)
          else
            position
          end
        end

        def scrollable_element
          Applitools::Calabash::Utils.get_ios_element(context, element.element_query, 0)
        end

        def entire_size
          @entire_size ||= query_entire_size
        end

        def query_entire_size
          result = NSSIZE.match(Applitools::Calabash::Utils.request_element(context, element, :contentSize).first)
          Applitools::RectangleSize.new(
            result[:width].to_i, result[:height].to_i
          ).scale_it!(screenshot_provider.density)
        end

        def query_current_position
          result = Applitools::Calabash::Utils.request_element(context, element, :contentOffset).first
          Applitools::Location.new(
            result['X'].to_i,
            result['Y'].to_i
          )
        end

        def store_original_position
          current_scrollable_element = Applitools::Calabash::Utils.request_element(context, element, :contentSize).first
          @original_position = Applitools::Location.new(
            current_scrollable_element['X'],
            current_scrollable_element['Y']
          )
        end

        def restore_original_position; end

        def scroll_it!
          scroll_in_one_dimension(:down) do |pos, is_first_vertical|
            scroll_in_one_dimension(:right, pos) do |position, is_first_horizontal|
              yield(position, !is_first_vertical, !is_first_horizontal) if block_given?
            end
          end
        end

        def scroll_in_one_dimension(direction, position = nil)
          previous_position = position || query_current_position
          is_first = true
          loop do
            yield(previous_position, is_first) if block_given?
            is_first = false if is_first
            context.scroll(element.element_query, direction)
            sleep NEXT_REQUEST_DELAY
            new_position = query_current_position
            return if previous_position == new_position
            previous_position = new_position
          end
        end

        def scroll_left_top
          scroll_in_one_dimension(:up) do |position, _is_first, _direction|
            scroll_in_one_dimension(:left, position)
          end
        end

        def eyes_window
          @eyes_window ||= Applitools::Region.from_location_size(element.location, element.size)
        end
      end
    end
  end
end
