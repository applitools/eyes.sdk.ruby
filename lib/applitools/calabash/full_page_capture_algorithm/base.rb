# frozen_string_literal: true

module Applitools
  module Calabash
    module FullPageCaptureAlgorithm
      class Base
        extend Applitools::Helpers
        extend Forwardable
        def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=

        attr_reader :context, :element, :screenshot_provider, :stitched_image, :debug_screenshot_provider

        DEFAULT_SLEEP_INTERVAL = 1

        def initialize(screenshot_provider, element, options = {})
          Applitools::ArgumentGuard.is_a?(element, 'element', Applitools::Calabash::CalabashElement)
          @screenshot_provider = screenshot_provider
          @element = element
          @context = screenshot_provider.context
          return unless options[:debug_screenshot_provider]
          Applitools::ArgumentGuard.is_a?(
            options[:debug_screenshot_provider],
            'options[:debug_screenshot_provider]',
            Applitools::DebugScreenshotProvider
          )
          @debug_screenshot_provider = options[:debug_screenshot_provider]
        end

        private

        def create_entire_image
          current_entire_size = entire_size
          @stitched_image = ::ChunkyPNG::Image.new(current_entire_size.width, current_entire_size.height)
        end

        def entire_content
          @entire_content ||= scrollable_element
        end

        abstract_method(:entire_size, true)
        abstract_method(:scrollable_element, true)
        abstract_method(:eyes_window, true)

        def put_it_on_canvas!(image, offset)
          debug_screenshot_provider.save(image, "#{offset.x} x #{offset.y}") if debug_screenshot_provider
          stitched_image.replace!(image, offset.x, offset.y)
        end
      end
    end
  end
end
