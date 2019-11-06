# frozen_string_literal: true

module Applitools::Selenium
  # @!visibility private
  class FullPageCaptureAlgorithm
    extend Forwardable
    def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=

    attr_reader :debug_screenshot_provider

    MAX_SCROLL_BAR_SIZE = 50
    MIN_SCREENSHOT_PART_HEIGHT = 10
    MIN_SCREENSHOT_PART_WIDTH = 10

    def initialize(options = {})
      @debug_screenshot_provider = options[:debug_screenshot_provider] ||
        Applitools::DebugScreenshotProvider.new.tag_access { '' }.debug_flag_access { false }
    end

    # Returns the stitched image.
    #
    # @param [Hash] options The options.
    # @option [Applitools::Selenium::TakesScreenshotImageProvider] :image_provider
    # @option [Applitools::Region] :region_to_check
    # @option [Applitools::Selenium::ScrollPositionProvider] :origin_provider
    # @option [Applitools::Selenium::ElementPositionProvider] :position_provider
    # @option [Applitools::Selenium::ContextBasedScaleProvider] :scale_provider
    # @option [Applitools::FixedCutProvider] :cut_provider
    # @option [Integer] :wait_before_screenshots The time to wait before taking screenshot.
    # @option [Faraday::Request::UrlEncoded] :eyes_screenshot_factory The images.
    # @return [Applitools::Image] The entire image.
    def get_stitched_region(options = {})
      logger.info 'get_stitched_region() has been invoked.'
      image_provider = options[:image_provider]
      region_provider = options[:region_to_check]
      origin_provider = options[:origin_provider]
      position_provider = options[:position_provider]
      scale_provider = options[:scale_provider]
      cut_provider = options[:cut_provider]
      wait_before_screenshot = options[:wait_before_screenshots]
      eyes_screenshot_factory = options[:eyes_screenshot_factory]
      stitching_overlap = options[:stitching_overlap] || MAX_SCROLL_BAR_SIZE
      top_left_position = options[:top_left_position] || Applitools::Location::TOP_LEFT

      logger.info "Region to check: #{region_provider.region(false)}"
      logger.info "Coordinates type: #{region_provider.coordinate_type}"

      original_position = origin_provider.state
      current_position = nil
      set_position_retries = 3
      while current_position.nil? ||
          (current_position == top_left_position) && set_position_retries > 0
        origin_provider.position = top_left_position
        sleep wait_before_screenshot
        current_position = origin_provider.current_position
        set_position_retries -= 1
      end

      unless current_position == top_left_position
        origin_provider.restore_state original_position
        raise Applitools::EyesError.new 'Couldn\'t set position to the top/left corner!'
      end

      logger.info "Current position: #{current_position}"

      logger.info 'Getting top/left image...'
      image = image_provider.take_screenshot
      debug_screenshot_provider.save(image, 'left_top_original')
      image = scale_provider.scale_image(image) if scale_provider
      debug_screenshot_provider.save(image, 'left_top_original_scaled')
      image = cut_provider.cut(image) if cut_provider
      debug_screenshot_provider.save(image, 'left_top_original_cutted')
      logger.info 'Done! Creating screenshot object...'
      screenshot = eyes_screenshot_factory.call(image)

      begin
        entire_size = position_provider.entire_size(image.width, image.height)
      rescue Applitools::EyesDriverOperationException => e
        logger.error "Failed to extract entire size of region context: #{e.message}"
        logger.error "Using image size instead: #{image.width}x#{image.height}"
        entire_size = Applitools::RectangleSize.new image.width, image.height
      end

      if region_provider.region(false).size.square > 0
        left_top_image = screenshot.sub_screenshot(region_provider.region(false), region_provider.coordinate_type).image
      else
        left_top_image = screenshot.image
      end
      debug_screenshot_provider.save_subscreenshot(left_top_image, region_provider.region(false))

      image = left_top_image.image

      part_image_size = Applitools::RectangleSize.new(
        [image.width - stitching_overlap, MIN_SCREENSHOT_PART_WIDTH].max,
        [image.height - stitching_overlap, MIN_SCREENSHOT_PART_HEIGHT].max
      )

      logger.info "Total size: #{entire_size}, image_part_size: #{part_image_size}"

      # Getting the list of sub-regions composing the whole region (we'll
      # take screenshot for each one).
      entire_page = Applitools::Region.from_location_size Applitools::Location::TOP_LEFT, entire_size

      # Notice that this might still happen even if we used
      # "getImagePart", since "entirePageSize" might be that of a frame.
      if image.width >= entire_size.width && image.height >= entire_size.height
        origin_provider.restore_state original_position
        return left_top_image
      end

      image_parts = entire_page.sub_regions(part_image_size)

      logger.info "Creating stitchedImage container. Size: #{entire_size}"

      stitched_image = ::ChunkyPNG::Image.new(entire_size.width, entire_size.height)
      logger.info 'Done! Adding initial screenshot..'
      logger.info "Initial part:(0,0) [#{image.width} x #{image.height}]"

      image.crop!(0,0,stitched_image.width < image.width ? stitched_image.width : image.width, stitched_image.height < image.height ? stitched_image.height : image.height)

      stitched_image.replace! image, 0, 0
      logger.info 'Done!'

      last_successful_location = Applitools::Location.new 0, 0
      last_successful_part_size = Applitools::RectangleSize.new image.width, image.height

      original_stitched_state = position_provider.state

      stitched_image_region = Applitools::Region.new(
        0,
        0,
        stitched_image.width,
        stitched_image.height
      )

      logger.info 'Getting the rest of the image parts...'

      # rubocop:disable Metrics/BlockLength
      image_parts.each_with_index do |part_regions, i|
        next unless i > 0

        part_region = part_regions.first
        intersection = part_regions.last

        logger.info "Taking screenshot for #{part_region}"

        position_provider.position = part_region
                                     .location
                                     .offset(top_left_position)
                                     .offset_negative(intersection.location)

        sleep wait_before_screenshot
        current_position = position_provider.current_position
        logger.info "Set position to #{current_position}"
        logger.info 'Getting image...'

        part_image = image_provider.take_screenshot(debug_suffix: "scrolled_(#{current_position})")
        part_image = scale_provider.scale_image part_image if scale_provider
        debug_screenshot_provider.save(part_image, 'scaled')
        part_image = cut_provider.cut part_image if cut_provider
        debug_screenshot_provider.save(part_image, 'cutted')

        logger.info 'Done!'

        a_screenshot = eyes_screenshot_factory.call(part_image)

        if region_provider.region(false).size.square > 0
          a_screenshot = a_screenshot.sub_screenshot(
            region_provider.region(false),
            Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative],
            false
          )
        end

        position_to_replace = current_position.offset(intersection.location)

        replacement_region = Applitools::Region.new(
          position_to_replace.x,
          position_to_replace.y,
          a_screenshot.width - intersection.size.width,
          a_screenshot.height - intersection.size.height
        )

        replacement_size = stitched_image_region.dup.intersect(replacement_region).size
        replacement_region_in_screenshot = Applitools::Region.from_location_size(
          Applitools::Location.from_any_attribute(intersection.location),
          replacement_size
        )

        image_to_stitch = a_screenshot.sub_screenshot(
          replacement_region_in_screenshot,
          Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative],
          false
        ).image

        logger.info 'Stitching part into the image container...'

        stitched_image.replace! image_to_stitch, position_to_replace.x, position_to_replace.y
        logger.info 'Done!'

        last_successful_location = Applitools::Location.for position_to_replace.x, position_to_replace.y
        next unless image_to_stitch.area > 0
        last_successful_part_size = Applitools::RectangleSize.new(
          image_to_stitch.width,
          image_to_stitch.height
        )
      end
      # rubocop:enable Metrics/BlockLength

      logger.info 'Stitching done!'

      position_provider.restore_state original_stitched_state
      origin_provider.restore_state original_position

      actual_image_width = last_successful_location.x + last_successful_part_size.width
      actual_image_height = last_successful_location.y + last_successful_part_size.height

      logger.info "Extracted entire size: #{entire_size}"
      logger.info "Actual stitched size: #{stitched_image.width} x #{stitched_image.height}"
      logger.info "Calculated stitched size: #{actual_image_width} x #{actual_image_height}"

      if actual_image_width < stitched_image.width || actual_image_height < stitched_image.height
        logger.info 'Trimming unnecessary margins...'
        stitched_image.crop!(0, 0,
          [actual_image_width, stitched_image.width].min,
          [actual_image_height, stitched_image.height].min)
        debug_screenshot_provider.save(stitched_image, 'trimmed')
        logger.info 'Done!'
      end

      logger.info 'Converting to screenshot...'
      result_screenshot = Applitools::Screenshot.from_any_image(stitched_image)
      debug_screenshot_provider.save(result_screenshot, 'full_page')
      logger.info 'Done converting!'
      result_screenshot
    end
  end
end
