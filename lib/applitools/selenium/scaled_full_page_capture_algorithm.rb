module Applitools::Selenium
  # @!visibility private
  class ScaledFullPageCaptureAlgorithm
    extend Forwardable
    def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=

    MAX_SCROLL_BAR_SIZE = 50
    MIN_SCREENSHOT_PART_HEIGHT = 10

    def get_stiched_region(options = {})
      logger.info 'get_stiched_region() has been invoked.'
      image_provider = options[:image_provider]
      region_provider = options[:region_to_check]
      origin_provider = options[:origin_provider]
      position_provider = options[:position_provider]
      cut_provider = options[:cut_provider]
      wait_before_screenshot = options[:wait_before_screenshots]
      eyes_screenshot_factory = options[:eyes_screenshot_factory]
      device_pixel_ratio = options[:device_pixel_ratio]

      logger.info "Region to check: #{region_provider.region}"
      logger.info "Coordinates type: #{region_provider.coordinate_type}"

      original_position = origin_provider.state
      current_position = nil
      set_position_retries = 3
      while current_position.nil? ||
          (current_position.x.nonzero? || current_position.y.nonzero?) && set_position_retries > 0
        origin_provider.position = Applitools::Location.new(0, 0)
        sleep wait_before_screenshot
        current_position = origin_provider.current_position
        set_position_retries -= 1
      end

      unless current_position.x.zero? && current_position.y.zero?
        origin_provider.restore_state original_position
        raise Applitools::EyesError.new 'Couldn\'t set position to the top/left corner!'
      end

      begin
        entire_size = position_provider.entire_size
        logger.info "Entire size of region context: #{entire_size}"
      rescue Applitools::EyesDriverOperationException => e
        logger.error "Failed to extract entire size of region context: #{e.message}"
        logger.error "Using image size instead: #{image.width}x#{image.height}"
        entire_size = Applitools::RectangleSize.new image.width, image.height
      end

      logger.info 'Getting top/left image...'
      image = image_provider.take_screenshot

      image = cut_provider.cut(image) if cut_provider
      logger.info 'Done! Creating screenshot object...'
      screenshot = eyes_screenshot_factory.call(image)

      if region_provider.coordinate_type
        left_top_image = screenshot.sub_screenshot(region_provider.region, region_provider.coordinate_type)
      else
        left_top_image = screenshot.sub_screenshot(
          Applitools::Region.from_location_size(Applitools::Location.new(0, 0), entire_size),
          Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative]
        )
      end

      image = left_top_image.image

      # Notice that this might still happen even if we used
      # "getImagePart", since "entirePageSize" might be that of a frame.

      if image.width >= entire_size.width && image.height >= entire_size.height
        origin_provider.restore_state original_position
        return image
      end

      part_image_size = Applitools::RectangleSize.new image.width,
        [image.height - MAX_SCROLL_BAR_SIZE, MIN_SCREENSHOT_PART_HEIGHT].max

      logger.info "Total size: #{entire_size}, image_part_size: #{part_image_size}"

      # Getting the list of sub-regions composing the whole region (we'll
      # take screenshot for each one).
      entire_page = Applitools::Region.from_location_size Applitools::Location::TOP_LEFT, entire_size
      image_parts = entire_page.sub_regions(part_image_size)

      logger.info "Creating stitchedImage container. Size: #{entire_size}"

      # Notice stitched_image uses the same type of image as the screenshots.
      # stitched_image = Applitools::Screenshot.from_region entire_size
      stitched_image = Applitools::Screenshot::ScaledImage.new(
        ::ChunkyPNG::Image.new(
          (entire_size.width * device_pixel_ratio).round,
          (entire_size.height * device_pixel_ratio).round
        ),
        device_pixel_ratio
      )
      logger.info 'Done! Adding initial screenshot..'
      logger.info "Initial part:(0,0) [#{image.width} x #{image.height}]"

      stitched_image.replace! image, 0, 0
      logger.info 'Done!'

      last_successful_location = Applitools::Location.new 0, 0
      last_successful_part_size = Applitools::RectangleSize.new image.width, image.height

      original_stitched_state = position_provider.state

      logger.info 'Getting the rest of the image parts...'

      image_parts.each_with_index do |part_region, i|
        next unless i > 0
        logger.info "Taking screenshot for #{part_region}"

        position_provider.position = part_region.location
        sleep wait_before_screenshot
        current_position = position_provider.current_position
        logger.info "Set position to #{current_position}"
        logger.info 'Getting image...'

        part_image = image_provider.take_screenshot
        part_image = cut_provider.cut part_image if cut_provider

        logger.info 'Done!'
        begin
          region_to_check = Applitools::Region.from_location_size(
            part_region.location.offset(region_provider.region.location), part_region.size
          )
          a_screenshot = eyes_screenshot_factory.call(part_image).sub_screenshot(region_to_check,
            Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative], false)
        rescue Applitools::OutOfBoundsException => e
          logger.error e.message
          break
        end

        logger.info 'Stitching part into the image container...'
        stitched_image.replace! a_screenshot.image, part_region.x, part_region.y
        logger.info 'Done!'

        last_successful_location = Applitools::Location.for part_region.x, part_region.y
        next unless a_screenshot
        last_successful_part_size = Applitools::RectangleSize.new(
          a_screenshot.image.width,
          a_screenshot.image.height
        )
      end

      logger.info 'Stitching done!'

      position_provider.restore_state original_stitched_state
      origin_provider.restore_state original_position

      actual_image_width = last_successful_location.x + last_successful_part_size.width
      actual_image_height = last_successful_location.y + last_successful_part_size.height

      logger.info "Extracted entire size: #{entire_size}"
      logger.info "Actual stitched size: #{stitched_image.width} x #{stitched_image.height}"
      logger.info "Actual stitched size: #{actual_image_width} x #{actual_image_height}"

      if actual_image_width < stitched_image.width || actual_image_height < stitched_image.height
        logger.info 'Trimming unnecessary margins...'
        stitched_image.crop!(0, 0, actual_image_width, actual_image_height)
        logger.info 'Done!'
      end

      Applitools::Screenshot.from_any_image(stitched_image.to_blob)
    end
  end
end
