require_relative 'base'
module Applitools
  module Calabash
    module FullPageCaptureAlgorithm
      class AndroidScrollView < Base
        attr_reader :stitched_image
        def initialize(*args)
          super
          @entire_content = nil
          @stitched_image = nil
          @original_position = nil
        end

        def get_stitched_region(scroll_to_top = true)
          create_entire_image
          store_original_position
          scroll_top if scroll_to_top

          scroll_it! do |scrollable_element|
            put_it_on_canvas!(
              screenshot_provider.capture_screenshot.sub_screenshot(
                eyes_window,
                Applitools::Calabash::EyesCalabashScreenshot::DRIVER,
                false,
                false
              ).image,
              element.location.offset_negative(scrollable_element.location)
            )
          end

          restore_original_position

          Applitools::Calabash::EyesCalabashAndroidScreenshot.new(
            Applitools::Screenshot.from_image(stitched_image),
            density: screenshot_provider.density
          )
        end

        private

        def put_it_on_canvas!(image, offset)
          stitched_image.replace!(image, offset.x, offset.y)
        end

        def entire_content
          @entire_content ||= scrollable_element
        end

        def scrollable_element
          child_query = "#{element.element_query} child * index:0"
          Applitools::Calabash::Utils.get_android_element(context, child_query, 0)
        end

        def entire_size
          entire_content.size
        end

        def scroll_top
          logger.info 'Scrolling up...'
          context.query(element.element_query, scrollTo: [0, 0])
          logger.info 'Done!'
        end

        def store_original_position
          scrollable_element = scrollable_element
          @original_position = Applitools::Location.new(scrollable_element.left, scrollable_element.top)
        end

        def restore_original_position
          return unless @original_position
          offset = @original_position.offset_negative(scrollable_element.location)
          context.query(element.element_query, scrollBy: [-offset.x, -offset.y])
          @original_position = nil
        end

        def scroll_it!
          scroll_vertical = true
          loop do
            scrollable = scrollable_element if scroll_vertical
            vertical_offset = element.location.offset_negative(scrollable.location).top
            scroll_vertical = false if vertical_offset + 1 >= scrollable.height - element.height
            yield(scrollable) if block_given?
            context.query(element.element_query, scrollBy: [0, element.height]) if scroll_vertical
            return unless scroll_vertical
          end
        end

        def create_entire_image
          current_entire_size = entire_size
          @stitched_image = ::ChunkyPNG::Image.new(current_entire_size.width, current_entire_size.height)
        end

        def eyes_window
          @eyes_window ||= Applitools::Region.from_location_size(element.location, element.size)
        end
      end
    end
  end
end