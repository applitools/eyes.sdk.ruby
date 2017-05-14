module Applitools::Selenium
  # @!visibility private
  class EyesWebDriverScreenshot < Applitools::EyesScreenshot
    SCREENSHOT_TYPES = {
      viewport: 'VIEPORT',
      entire_frame: 'ENTIRE_FRAME'
    }.freeze

    INIT_CALLBACKS = {
      [:driver, :screenshot_type, :frame_location_in_screenshot].sort => :initialize_main,
      [:driver, :force_offset].sort => :initialize_main,
      [:driver].sort => :initialize_main,
      [:driver, :position_provider].sort => :initialize_main,
      [:driver, :entire_frame_size].sort => :initialize_for_element,
      [:driver, :entire_frame_size, :frame_location_in_screenshot].sort => :initialize_for_element
    }.freeze

    attr_accessor :driver
    attr_accessor :frame_chain
    private :frame_chain=

    class << self
      alias _new new

      # Creates new image.
      #
      # @param [Array] *args The arguments.
      # @return [Applitools::Screenshot] The image.
      def new(*args)
        image = args.shift
        raise Applitools::EyesIllegalArgument.new 'image is expected to be Applitools::Screenshot!' unless
            image.is_a? Applitools::Screenshot

        options = args.first
        if options.is_a? Hash
          result = _new(image)
          callback = INIT_CALLBACKS[options.keys.sort]
          return result.tap { |o| o.send callback, options } if result.respond_to? callback
          raise Applitools::EyesIllegalArgument.new 'Can\'t find an appropriate initializer!'
        end
        raise Applitools::EyesIllegalArgument.new "#{self.class}.initialize(): Hash is expected as an argument!"
      end

      # Calculates the frame location in the screenshot.
      #
      # @param [Applitools::Selenium::FrameChain] frame_chain The driver's frame chain.
      # @param [String] screenshot_type The type of the screenshot.
      # @param [Logger] logger The logger instance.
      # @return [Applitools::Location] The location in the screenshot.
      def calc_frame_location_in_screenshot(frame_chain, screenshot_type, logger)
        frame_chain = Applitools::Selenium::FrameChain.new other: frame_chain
        logger.info 'Getting first frame...'
        first_frame = frame_chain.shift
        logger.info 'Done!'
        location_in_screenshot = Applitools::Location.for first_frame.location

        if screenshot_type == SCREENSHOT_TYPES[:viewport]
          default_content_scroll = first_frame.parent_scroll_position
          location_in_screenshot.offset_negative(
            Applitools::Location.for(default_content_scroll.x, default_content_scroll.y)
          )
        end

        logger.info 'Iterating over frames...'
        frame_chain.each do |frame|
          location_in_screenshot.offset(Applitools::Location.for(frame.location.x, frame.location.y))
                                .offset_negative(
                                  Applitools::Location.for(
                                    frame.parent_scroll_position.x, frame.parent_scroll_position.y
                                  )
                                )
        end
        location_in_screenshot
      end
    end

    # Initialize element.
    #
    # @param [Hash] options The options.
    # @option options [Symbol] :driver Applitools driver instance.
    # @option options [Symbol] :entire_frame_size The size of the entire frame.
    # @option options [Symbol] :entire_frame The frame instance.
    # @option options [Symbol] :frame_location_in_screenshot The location of the frame in the screenshot.
    def initialize_for_element(options = {})
      Applitools::ArgumentGuard.not_nil options[:driver], 'options[:driver]'
      Applitools::ArgumentGuard.not_nil options[:entire_frame_size], 'options[:entire_frame_size]'
      entire_frame_size = options[:entire_frame_size]
      self.driver = options[:driver]
      self.frame_chain = driver.frame_chain
      self.screenshot_type = SCREENSHOT_TYPES[:entire_frame]
      self.scroll_position = Applitools::Location.new(0, 0)
      self.scroll_position = Applitools::Location.new(0, 0).offset(options[:frame_location_in_screenshot]) if
          options[:frame_location_in_screenshot].is_a? Applitools::Location
      self.frame_location_in_screenshot = Applitools::Location.new(0, 0)
      self.frame_window = Applitools::Region.new(0, 0, entire_frame_size.width, entire_frame_size.height)
    end

    # Initializes class properties.
    #
    # @param [Hash] options The options.
    # @option options [Symbol] :driver Wrapped Selenium driver instance.
    # @option options [Symbol] :position_provider The ScrollPositionProvider.
    # @option options [Symbol] :viewport The viewport instance.
    # @option options [Symbol] :entire_frame The entire frame instance.
    # @option options [Symbol] :screenshot_type The screenshot type.
    # @option options [Symbol] :frame_location_in_screenshot The frame location in the screenshot.
    # @option options [Symbol] :force_offset Whether to force offset or not.
    def initialize_main(options = {})
      # options = {screenshot_type: SCREENSHOT_TYPES[:viewport]}.merge options

      Applitools::ArgumentGuard.hash options, 'options', [:driver]
      Applitools::ArgumentGuard.not_nil options[:driver], 'options[:driver]'

      self.driver = options[:driver]
      self.position_provider = Applitools::Selenium::ScrollPositionProvider.new driver if
          options[:position_provider].nil?

      viewport_size = driver.default_content_viewport_size

      self.frame_chain = driver.frame_chain
      if !frame_chain.empty?
        frame_size = frame_chain.current_frame_size
      else
        begin
          frame_size = position_provider.entire_size
        rescue
          frame_size = viewport_size
        end
      end

      begin
        self.scroll_position = position_provider.current_position
      rescue
        self.scroll_position = Applitools::Location.new(0, 0)
      end

      if options[:screenshot_type].nil?
        self.screenshot_type = if image.width <= viewport_size.width && image.height <= viewport_size.height
                                 SCREENSHOT_TYPES[:viewport]
                               else
                                 SCREENSHOT_TYPES[:entire_frame]
                               end
      else
        self.screenshot_type = options[:screenshot_type]
      end

      if options[:frame_location_in_screenshot].nil?
        if !frame_chain.empty?
          self.frame_location_in_screenshot = self.class.calc_frame_location_in_screenshot(
            frame_chain, screenshot_type, logger
          )
        else
          self.frame_location_in_screenshot = Applitools::Location.new(0, 0)
        end
      else
        self.frame_location_in_screenshot = options[:frame_location_in_screenshot]
      end

      self.force_offset = Applitools::Location::TOP_LEFT
      self.force_offset = options[:force_offset] if options[:force_offset]

      logger.info 'Calculating frame window..'
      self.frame_window = Applitools::Region.from_location_size(frame_location_in_screenshot, frame_size)
      frame_window.intersect Applitools::Region.new(0, 0, image.width, image.height)

      raise Applitools::EyesError.new 'Got empty frame window for screenshot!' if
          frame_window.width <= 0 || frame_window.height <= 0

      logger.info 'Done!'
    end

    # def scroll_position
    #   begin
    #     position_provider.state
    #   rescue
    #     Applitools::Location.new(0,0)
    #   end
    # end

    # Convert the location.
    #
    # @param [Applitools::Location] location.
    # @param [Applitools::EyesScreenshot::COORDINATE_TYPES] from Source.
    # @param [Applitools::EyesScreenshot::COORDINATE_TYPES] to Destination.
    # @return [Applitools::Location] The converted location.
    def convert_location(location, from, to)
      Applitools::ArgumentGuard.not_nil location, 'location'
      Applitools::ArgumentGuard.not_nil from, 'from'
      Applitools::ArgumentGuard.not_nil to, 'to'

      result = Applitools::Location.for location
      return result if from == to
      # if frame_chain.size.zero? && screenshot_type == SCREENSHOT_TYPES[:entire_frame]
      #   if (from == Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative] ||
      #       from == Applitools::EyesScreenshot::COORDINATE_TYPES[:context_as_is]) &&
      #       to == Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
      #     result.offset frame_location_in_screenshot
      #   elsif from == Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is] &&
      #       (to == Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative] ||
      #        to == Applitools::EyesScreenshot::COORDINATE_TYPES[:context_as_is])
      #     result.offset_negative frame_location_in_screenshot
      #   end
      # end

      case from
      when Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative]
        case to
        when Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
          result.offset_negative scroll_position
          result.offset frame_location_in_screenshot
        else
          raise Applitools::EyesCoordinateTypeConversionException.new "Can't convert coordinates from #{from} to #{to}"
        end
      when Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
        case to
        when Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative]
          result.offset_negative frame_location_in_screenshot
          result.offset scroll_position
        else
          raise Applitools::EyesCoordinateTypeConversionException.new "Can't convert coordinates from #{from} to #{to}"
        end
      else
        raise Applitools::EyesCoordinateTypeConversionException.new "Can't convert coordinates from #{from} to #{to}"
      end

      result
    end

    def frame_chain
      Applitools::Selenium::FrameChain.new other: @frame_chain
    end

    # Returns the intersected region.
    #
    # @param [Applitools::Selenium::Region] region The relevant region.
    # @param [Applitools::EyesScreenshot::COORDINATE_TYPES] original_coordinate_types The type of
    # the original coordinates.
    # @param [Applitools::EyesScreenshot::COORDINATE_TYPES] result_coordinate_types The type of the
    # original coordinates.
    # @return [Applitools::Region] The intersected region.
    def intersected_region(region, original_coordinate_types, result_coordinate_types)
      return Applitools::Region::EMPTY if region.empty?
      intersected_region = convert_region_location(
        region, original_coordinate_types, Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
      )
      case original_coordinate_types
      when Applitools::EyesScreenshot::COORDINATE_TYPES[:context_as_is]
        nil
      when Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative]
        intersected_region.intersect frame_window
      when Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
        intersected_region.intersect Applitools::Region.new(0, 0, image.width, image.height)
      else
        raise Applitools::EyesCoordinateTypeConversionException.new(
          "Unknown coordinates type: #{original_coordinate_types}"
        )
      end

      return intersected_region if intersected_region.empty?
      convert_region_location(
        intersected_region,
        Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is],
        result_coordinate_types
      )
    end

    # Returns the location in the screenshot.
    #
    # @param [Applitools::Location] location The location.
    # @param [Applitools::EyesScreenshot::COORDINATE_TYPES] coordinate_type The type of the coordinate.
    # @return [Applitools::Location] The location instance in the screenshot.
    def location_in_screenshot(location, coordinate_type)
      location = convert_location(
        location, coordinate_type, Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
      )
      unless frame_window.contains?(location.x, location.y)
        raise Applitools::OutOfBoundsException.new(
          "Location #{location} (#{coordinate_type}) is not visible in screenshot!"
        )
      end
      location
    end

    # Gets a sub-screenshot of a region.
    #
    # @param [Applitools::Region] region The relevant region for taking screenshot.
    # @param [Applitools::EyesScreenshot::COORDINATE_TYPES] coordinate_type The coordinate type.
    # @param [Boolean] throw_if_clipped Whether to throw if screenshot is out of bounds.
    # @return [Applitools::Screenshot] The sub screenshot.
    def sub_screenshot(region, coordinate_type, throw_if_clipped = false, force_nil_if_clipped = false)
      logger.info "get_subscreenshot(#{region}, #{coordinate_type}, #{throw_if_clipped})"
      Applitools::ArgumentGuard.not_nil region, 'region'
      Applitools::ArgumentGuard.not_nil coordinate_type, 'coordinate_type'

      region_to_check = Applitools::Region.from_location_size(
        region.location.offset_negative(force_offset), region.size
      )

      as_is_subscreenshot_region = intersected_region region_to_check, coordinate_type,
        Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]

      if as_is_subscreenshot_region.empty? || (throw_if_clipped && !as_is_subscreenshot_region.size == region.size)
        return nil if force_nil_if_clipped
        raise Applitools::OutOfBoundsException.new "Region #{region} (#{coordinate_type}) is out" \
          " of screenshot bounds [#{frame_window}]"
      end

      sub_screenshot_image = Applitools::Screenshot.from_image image.crop(as_is_subscreenshot_region.left,
        as_is_subscreenshot_region.top, as_is_subscreenshot_region.width,
        as_is_subscreenshot_region.height)

      context_relative_region_location = convert_location as_is_subscreenshot_region.location,
        Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is],
        Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative]

      result = self.class.new sub_screenshot_image, driver: driver,
        entire_frame_size: Applitools::RectangleSize.new(sub_screenshot_image.width, sub_screenshot_image.height),
        frame_location_in_screenshot: context_relative_region_location
      logger.info 'Done!'
      result
    end

    private

    attr_accessor :position_provider, :scroll_position, :screenshot_type, :frame_location_in_screenshot,
      :frame_window, :force_offset
  end
end
