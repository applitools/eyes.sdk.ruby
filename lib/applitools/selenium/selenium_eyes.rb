# frozen_string_literal: false

module Applitools::Selenium
  # The main API gateway for the SDK
  class SeleniumEyes < Applitools::EyesBase
    include Applitools::Selenium::Concerns::SeleniumEyes
    # @!visibility private
    UNKNOWN_DEVICE_PIXEL_RATIO = 0

    # The pixel ratio will be used if detection of device pixel ratio is failed
    DEFAULT_DEVICE_PIXEL_RATIO = 1

    DEFAULT_WAIT_BEFORE_SCREENSHOTS = 0.1 # Seconds

    DEFAULT_STITCHING_OVERLAP = 50 # Pixels

    ENTIRE_ELEMENT_SCREENSHOT = 0

    FULLPAGE_SCREENSHOT = 1

    VIEWPORT_SCREENSHOT = 2

    extend Forwardable
    # @!visibility public

    class << self
      def eyes_driver(driver, eyes = nil)
        if driver.respond_to? :driver_for_eyes
          driver.driver_for_eyes eyes
        else
          unless driver.is_a?(Applitools::Selenium::Driver)
            Applitools::EyesLogger.warn("Unrecognized driver type: (#{driver.class.name})!")
            is_mobile_device = driver.respond_to?(:capabilities) && driver.capabilities['platformName']
            Applitools::Selenium::Driver.new(eyes, driver: driver, is_mobile_device: is_mobile_device)
          end
          raise Applitools::EyesError.new "Unknown driver #{driver}!"
        end
      end

      def obtain_screenshot_type(is_element, inside_a_frame, stitch_content, force_fullpage)
        if stitch_content || force_fullpage
          unless inside_a_frame
            return FULLPAGE_SCREENSHOT if force_fullpage && !stitch_content
            return FULLPAGE_SCREENSHOT if stitch_content && !is_element
          end
          return ENTIRE_ELEMENT_SCREENSHOT if inside_a_frame
          return ENTIRE_ELEMENT_SCREENSHOT if stitch_content
        else
          return VIEWPORT_SCREENSHOT unless stitch_content || force_fullpage
        end
        VIEWPORT_SCREENSHOT
      end

      # Set the viewport size.
      #
      # @param [Applitools::Selenium::Driver] driver The driver instance.
      # @param [Hash] viewport_size The required browser's viewport size.
      def set_viewport_size(driver, viewport_size)
        Applitools::ArgumentGuard.not_nil(driver, 'Driver')
        Applitools::ArgumentGuard.not_nil(viewport_size, 'viewport_size')
        Applitools::ArgumentGuard.is_a?(viewport_size, 'viewport_size', Applitools::RectangleSize)
        begin
          Applitools::Utils::EyesSeleniumUtils.set_viewport_size eyes_driver(driver), viewport_size
        rescue => e
          Applitools::EyesLogger.error e.class
          Applitools::EyesLogger.error e.message
          raise Applitools::EyesError.new 'Failed to set viewport size!'
        end
      end
    end

    # @!attribute [rw] force_full_page_screenshot
    #   Forces a full page screenshot (by scrolling and stitching) if the
    #   browser only supports viewport screenshots.
    #   @return [boolean] force full page screenshot flag
    # @!attribute [rw] wait_before_screenshots
    #   Sets the time to wait just before taking a screenshot (e.g., to allow
    #   positioning to stabilize when performing a full page stitching).
    #   @return [Float] The time to wait (Seconds). Values
    #     smaller or equal to 0, will cause the default value to be used.
    # @!attribute [rw] hide_scrollbars
    #   Turns on/off hiding scrollbars before taking a screenshot
    #   @return [boolean] hide_scrollbars flag
    # @!attribute [rw] scroll_to_region
    #   If set to +true+ browser will scroll to specified region (even it is out of viewport window)
    #     when check_region is called
    #   @return [boolean] scroll_to_region flag
    # @!attribute [rw] stitch_mode
    #   May be set to :CSS or :SCROLL (:SCROLL is default).
    #   When :CSS - SDK will use CSS transitions to perform scrolling, otherwise it will use Javascript
    #   window.scroll_to() function for scrolling purposes
    #   @return [boolean] stitch_mode (:CSS or :SCROLL)
    # @!attribute [Applitools::RectangleSize] explicit_entire_size
    #   May be set to an Applitools::RectangleSize instance or +nil+ (default).
    #   @return [Applitools::RectangleSize] explicit_entire_size

    attr_accessor :base_agent_id, :screenshot, :force_full_page_screenshot, :hide_scrollbars,
      :wait_before_screenshots, :debug_screenshots, :stitch_mode, :disable_horizontal_scrolling,
      :disable_vertical_scrolling, :explicit_entire_size, :debug_screenshot_provider, :stitching_overlap,
      :full_page_capture_algorithm_left_top_offset, :screenshot_type, :send_dom, :use_dom, :enable_patterns,
      :config
    attr_reader :driver

    def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=
    def_delegators 'config', *Applitools::Selenium::Configuration.methods_to_delegate

    # Creates a new (possibly disabled) Eyes instance that interacts with the
    # Eyes Server at the specified url.
    #
    # @param server_url The Eyes Server URL.
    def initialize(*args)
      ensure_config
      super
      self.base_agent_id = "eyes.selenium.ruby/#{Applitools::VERSION}".freeze
      self.check_frame_or_element = false
      self.region_to_check = nil
      self.force_full_page_screenshot = false
      self.dont_get_title = false
      self.hide_scrollbars = false
      self.device_pixel_ratio = UNKNOWN_DEVICE_PIXEL_RATIO
      self.stitch_mode = Applitools::STITCH_MODE[:scroll]
      self.wait_before_screenshots = DEFAULT_WAIT_BEFORE_SCREENSHOTS
      self.region_visibility_strategy = MoveToRegionVisibilityStrategy.new
      self.debug_screenshots = false
      self.debug_screenshot_provider = Applitools::DebugScreenshotProvider.new
                                                                          .tag_access { tag_for_debug }
                                                                          .debug_flag_access { debug_screenshots }
      self.disable_horizontal_scrolling = false
      self.disable_vertical_scrolling = false
      self.explicit_entire_size = nil
      self.force_driver_resolution_as_viewport_size = false
      self.stitching_overlap = DEFAULT_STITCHING_OVERLAP
      self.full_page_capture_algorithm_left_top_offset = Applitools::Location::TOP_LEFT
      self.send_dom = false
      self.use_dom = false
      self.enable_patterns = false
      self.prevent_dom_processing = false
    end

    def ensure_config
      self.config = Applitools::Selenium::Configuration.new
    end

    def configure
      return unless block_given?
      yield(config)
    end

    # Starts a test
    #
    # @param options [Hash] options
    # @option options :driver The driver that controls the browser hosting the application
    #   under the test. (*Required* option)
    # @option options [String] :app_name The name of the application under the test. (*Required* option)
    # @option options [String] :test_name The test name (*Required* option)
    # @option options [String | Hash] :viewport_size The required browser's viewport size
    #   (i.e., the visible part of the document's body) or +nil+ to use the current window's viewport.
    # @option options :session_type The type of the test (e.g., standard test / visual performance test).
    #   Default value is 'SEQUENTAL'
    # @return [Applitools::Selenium::Driver] A wrapped web driver which enables Eyes
    #   trigger recording and frame handling
    def open(options = {})
      original_driver = options.delete(:driver)
      options[:viewport_size] = Applitools::RectangleSize.from_any_argument options[:viewport_size] if
          options[:viewport_size]
      Applitools::ArgumentGuard.not_nil original_driver, 'options[:driver]'
      # Applitools::ArgumentGuard.hash options, 'open(options)', [:app_name, :test_name]

      if disabled?
        logger.info('Ignored')
        return driver
      end

      @driver = self.class.eyes_driver(original_driver, self)
      perform_driver_specific_settings(original_driver)

      self.device_pixel_ratio = UNKNOWN_DEVICE_PIXEL_RATIO
      self.position_provider = self.class.position_provider(
        stitch_mode, driver, disable_horizontal_scrolling, disable_vertical_scrolling, explicit_entire_size
      )

      self.eyes_screenshot_factory = lambda do |image|
        Applitools::Selenium::ViewportScreenshot.new(
          image, driver: @driver, force_offset: position_provider.force_offset
        )
      end

      open_base(options) do
        self.viewport_size = nil if force_driver_resolution_as_viewport_size
        ensure_running_session
      end
      if runner
        runner.add_batch(batch.id) do
          server_connector.close_batch(batch.id)
        end
      end
      @driver
    end

    def perform_driver_specific_settings(original_driver)
      modifier = original_driver.class.to_s.downcase.gsub(/::/, '_')
      method_name = "perform_driver_settings_for_#{modifier}"
      send(method_name) if respond_to?(method_name, :include_private)
    end

    private :perform_driver_specific_settings

    # @!visibility private
    def title
      return driver.title unless dont_get_title
    rescue StandardError => e
      logger.warn "failed (#{e.message})"
      self.dont_get_title = false
      ''
    end

    # @!visibility private
    def get_viewport_size(web_driver = driver)
      Applitools::ArgumentGuard.not_nil 'web_driver', web_driver
      Applitools::Utils::EyesSeleniumUtils.extract_viewport_size(driver)
    end

    # Takes a snapshot and matches it with the expected output.
    #
    # @param [String] name The name of the tag.
    # @param [Applitools::Selenium::Target] target which area of the window to check.
    # @return [Applitools::MatchResult] The match results.
    def check(name, target)
      logger.info "check(#{name}) is called"
      self.tag_for_debug = name
      Applitools::ArgumentGuard.is_a? target, 'target', Applitools::Selenium::Target
      target_to_check = target.finalize
      original_overflow = nil
      original_position_provider = position_provider
      original_force_full_page_screenshot = force_full_page_screenshot

      eyes_element = nil
      timeout = target_to_check.options[:timeout] || USE_DEFAULT_MATCH_TIMEOUT

      self.eyes_screenshot_factory = lambda do |image|
        Applitools::Selenium::ViewportScreenshot.new(
          image,
          region_provider: region_to_check
        )
      end

      # self.prevent_dom_processing = !((!target.options[:send_dom].nil? && target.options[:send_dom]) ||
      #     send_dom || stitch_mode == Applitools::STITCH_MODE[:css])

      self.prevent_dom_processing = !((!target.options[:send_dom].nil? && target.options[:send_dom]) ||
          send_dom)

      check_in_frame target_frames: target_to_check.frames do
        begin
          match_data = Applitools::MatchWindowData.new
          match_data.tag = name
          update_default_settings(match_data)
          eyes_element = target_to_check.region_to_check.call(driver)

          unless force_full_page_screenshot
            region_visibility_strategy.move_to_region(
              original_position_provider,
              Applitools::Location.new(eyes_element.location.x.to_i, eyes_element.location.y.to_i)
            )
            driver.find_element(:css, 'html').scroll_data_attribute = true
          end

          region_provider = Applitools::Selenium::RegionProvider.new(driver, region_for_element(eyes_element))

          self.region_to_check = region_provider

          match_data.read_target(target_to_check, driver)
          match_data.use_dom = use_dom unless match_data.use_dom
          match_data.enable_patterns = enable_patterns unless match_data.enable_patterns

          is_element = eyes_element.is_a? Applitools::Selenium::Element
          inside_a_frame = !driver.frame_chain.empty?

          self.screenshot_type = self.class.obtain_screenshot_type(
            is_element,
            inside_a_frame,
            target_to_check.options[:stitch_content],
            force_full_page_screenshot
          )

          case screenshot_type
          when ENTIRE_ELEMENT_SCREENSHOT
            if eyes_element.is_a? Applitools::Selenium::Element
              original_overflow = eyes_element.overflow
              eyes_element.overflow = 'hidden'
              eyes_element.scroll_data_attribute = true
              eyes_element.overflow_data_attribute = original_overflow
              self.position_provider = Applitools::Selenium::CssTranslateElementPositionProvider.new(
                driver,
                eyes_element
              )
            end
          end

          check_window_base(
            region_provider, timeout, match_data
          )
        ensure
          eyes_element.overflow = original_overflow unless original_overflow.nil?
          self.check_frame_or_element = false
          self.force_full_page_screenshot = original_force_full_page_screenshot
          self.position_provider = original_position_provider
          self.region_to_check = nil
          self.full_page_capture_algorithm_left_top_offset = Applitools::Location::TOP_LEFT
          region_visibility_strategy.return_to_original_position original_position_provider
        end
        # rubocop:enable BlockLength
      end
      self.prevent_dom_processing = false
    end

    # Creates a region instance.
    #
    # @param [Applitools::Element] element The element.
    # @return [Applitools::Region] The relevant region.
    def region_for_element(element)
      return element if element.is_a? Applitools::Region

      p = element.location
      d = element.size

      border_left_width = element.border_left_width
      border_top_width = element.border_top_width
      border_right_width = element.border_right_width
      border_bottom_width = element.border_bottom_width

      Applitools::Region.new(
        p.x.round + border_left_width,
        p.y.round + border_top_width,
        d.width - border_left_width - border_right_width,
        d.height - border_top_width - border_bottom_width
      ).tap do |r|
        border_padding = Applitools::PaddingBounds.new(
          border_left_width,
          border_top_width,
          border_right_width,
          border_bottom_width
        )
        r.padding(border_padding)
      end
    end

    private :check_in_frame
    private :region_for_element

    # @!visibility private
    def scroll_to_region
      region_visibility_strategy.is_a? Applitools::Selenium::MoveToRegionVisibilityStrategy
    end

    # @!visibility private
    def scroll_to_region=(value)
      if value
        self.region_visibility_strategy = Applitools::Selenium::MoveToRegionVisibilityStrategy.new
      else
        self.region_visibility_strategy = Applitools::Selenium::NopRegionVisibilityStrategy.new
      end
    end

    def dom_data
      return {} if prevent_dom_processing
      begin
        Applitools::Selenium::DomCapture.full_window_dom(driver, server_connector, logger, position_provider)
      rescue Applitools::EyesError => e
        logger.error "DOM capture failed! #{e.message}"
        return {}
      end
    end

    def close_async
      close(false)
    end

    private

    attr_accessor :check_frame_or_element, :region_to_check, :dont_get_title,
      :device_pixel_ratio, :position_provider, :scale_provider, :tag_for_debug,
      :region_visibility_strategy, :eyes_screenshot_factory, :force_driver_resolution_as_viewport_size,
      :prevent_dom_processing

    def image_provider
      Applitools::Selenium::TakesScreenshotImageProvider.new(
        driver,
        debug_screenshot_provider: debug_screenshot_provider
      )
    end

    def capture_screenshot
      logger.info 'Getting screenshot (capture_screenshot() has been invoked)'

      update_scaling_params

      if hide_scrollbars
        begin
          original_overflow = Applitools::Utils::EyesSeleniumUtils.hide_scrollbars driver
          driver.find_element(:css, 'html').overflow_data_attribute = original_overflow
        rescue Applitools::EyesDriverOperationException => e
          logger.warn "Failed to hide scrollbars! Error: #{e.message}"
        end
      end

      begin
        algo = Applitools::Selenium::FullPageCaptureAlgorithm.new(
          debug_screenshot_provider: debug_screenshot_provider
        )
        case screenshot_type
        when ENTIRE_ELEMENT_SCREENSHOT
          self.screenshot = entire_element_screenshot(algo)
        when FULLPAGE_SCREENSHOT
          self.screenshot = full_page_screenshot(algo)
        when VIEWPORT_SCREENSHOT
          self.screenshot = viewport_screenshot
        end
      ensure
        begin
          Applitools::Utils::EyesSeleniumUtils.set_overflow driver, original_overflow
        rescue Applitools::EyesDriverOperationException => e
          logger.warn "Failed to revert overflow! Error: #{e.message}"
        end
      end
    end

    def full_page_screenshot(algo)
      logger.info 'Full page screenshot requested'
      original_frame = driver.frame_chain
      driver.switch_to.default_content
      region_provider = Applitools::Selenium::RegionProvider.new(driver, Applitools::Region::EMPTY)

      full_page_image = algo.get_stitched_region(
        image_provider: image_provider,
        region_to_check: region_provider,
        origin_provider: Applitools::Selenium::ScrollPositionProvider.new(driver),
        position_provider: position_provider,
        scale_provider: scale_provider,
        cut_provider: cut_provider,
        wait_before_screenshots: wait_before_screenshots,
        eyes_screenshot_factory: eyes_screenshot_factory,
        stitching_overlap: stitching_overlap
      )

      # binding.pry
      unless original_frame.empty?
        logger.info 'Switching back to original frame...'
        driver.switch_to.frames frame_chain: original_frame
        logger.info 'Done switching!'
      end
      logger.info 'Creating EyesWebDriver screenshot instance..'
      result = Applitools::Selenium::FullpageScreenshot.new(
        full_page_image,
        region_provider: region_to_check
      )
      logger.info 'Done creating EyesWebDriver screenshot instance!'
      result
    end

    def entire_element_screenshot(algo)
      logger.info 'Entire element screenshot requested'
      entire_frame_or_element = algo.get_stitched_region(
        image_provider: image_provider,
        region_to_check: region_to_check,
        origin_provider: position_provider,
        position_provider: position_provider,
        scale_provider: scale_provider,
        cut_provider: cut_provider,
        wait_before_screenshots: wait_before_screenshots,
        eyes_screenshot_factory: eyes_screenshot_factory,
        stitching_overlap: stitching_overlap,
        top_left_position: full_page_capture_algorithm_left_top_offset
      )

      logger.info 'Building screenshot object (EyesStitchedElementScreenshot)...'
      result = Applitools::Selenium::EntireElementScreenshot.new(
        entire_frame_or_element,
        region_provider: region_to_check
      )
      logger.info 'Done!'
      result
    end

    def viewport_screenshot
      logger.info 'Viewport screenshot requested'
      sleep wait_before_screenshots
      image = image_provider.take_screenshot
      scale_provider.scale_image(image) if scale_provider
      local_cut_provider = (
      cut_provider || Applitools::Selenium::FixedCutProvider.viewport(image, viewport_size, region_to_check)
      )
      local_cut_provider.cut(image) if local_cut_provider
      eyes_screenshot_factory.call(image)
    end

    def vp_size=(value, skip_check_if_open = false)
      raise Applitools::EyesNotOpenException.new 'set_viewport_size: Eyes not open!' unless skip_check_if_open || open?
      original_frame = driver.frame_chain
      driver.switch_to.default_content
      begin
        Applitools::Utils::EyesSeleniumUtils.set_viewport_size driver, value
      rescue => e
        logger.error e.class.to_s
        logger.error e.message
        raise Applitools::TestFailedError.new "#{e.class} - #{e.message}"
      ensure
        driver.switch_to.frames(frame_chain: original_frame)
      end
    end

    alias set_viewport_size vp_size=

    def get_driver(options)
      # TODO: remove the "browser" related block when possible. It's for backward compatibility.
      if options.key?(:browser)
        logger.warn('"browser" key is deprecated, please use "driver" instead.')
        return options[:browser]
      end

      options.fetch(:driver, nil)
    end

    def update_scaling_params
      return unless device_pixel_ratio == UNKNOWN_DEVICE_PIXEL_RATIO

      logger.info 'Trying to extract device pixel ratio...'
      begin
        self.device_pixel_ratio = Applitools::Utils::EyesSeleniumUtils.device_pixel_ratio(driver)
      rescue Applitools::EyesDriverOperationException
        logger.warn 'Failed to extract device pixel ratio! Using default.'
        self.device_pixel_ratio = DEFAULT_DEVICE_PIXEL_RATIO
      end

      logger.info "Device pixel_ratio: #{device_pixel_ratio}"
      logger.info 'Setting scale provider...'

      begin
        self.scale_provider = Applitools::Selenium::ContextBasedScaleProvider.new(position_provider.entire_size,
          viewport_size, device_pixel_ratio)
      rescue StandardError
        logger.info 'Failed to set ContextBasedScaleProvider'
        logger.info 'Using FixedScaleProvider instead'
        self.scale_provider = Applitools::FixedScaleProvider.new(1.to_f / device_pixel_ratio)
      end
      logger.info 'Done!'
    end

    def _add_text_trigger(control, text)
      unless last_screenshot
        logger.info "Ignoring #{text} (no screenshot)"
        return
      end

      unless driver.frame_chain.same_frame_chain? last_screenshot.frame_chain
        logger.info "Ignoring #{text} (different_frame)"
        return
      end

      add_text_trigger_base(control, text)
    end

    def add_text_trigger(control, text)
      if disabled?
        logger.info "Ignoring #{text} (disabled)"
        return
      end

      Applitools::ArgumentGuard.not_nil control, 'control'
      return _add_text_trigger(control, text) if control.is_a? Applitools::Region

      pl = control.location
      ds = control.size

      element_region = Applitools::Region.new(pl.x, pl.y, ds.width, ds.height)

      return _add_text_trigger(element_region, text) if control.is_a? Applitools::Selenium::Element
    end

    def add_mouse_trigger(mouse_action, element)
      if disabled?
        logger.info "Ignoring #{mouse_action} (disabled)"
        return
      end

      if element.is_a? Hash
        return add_mouse_trigger_by_region_and_location(mouse_action, element[:region], element[:location]) if
            element.key?(:location) && element.key?(:region)
        raise Applitools::EyesIllegalArgument.new 'Element[] doesn\'t contain required keys!'
      end

      Applitools::ArgumentGuard.not_nil element, 'element'
      Applitools::ArgumentGuard.is_a? element, 'element', Applitools::Selenium::Element

      pl = element.location
      ds = element.size

      element_region = Applitools::Region.new(pl.x, pl.y, ds.width, ds.height)

      unless last_screenshot
        logger.info "Ignoring #{mouse_action} (no screenshot)"
        return
      end

      unless driver.frame_chain.same_frame_chain? last_screenshot.frame_chain
        logger.info "Ignoring #{mouse_action} (different_frame)"
        return
      end

      add_mouse_trigger_base(mouse_action, element_region, element_region.middle_offset)
    end

    # control - Region
    # cursor - Location
    def add_mouse_trigger_by_region_and_location(mouse_action, control, cursor)
      unless last_screenshot
        logger.info "Ignoring #{mouse_action} (no screenshot)"
        return
      end

      Applitools::ArgumentGuard.is_a? control, 'control', Applitools::Region
      Applitools::ArgumentGuard.is_a? cursor, 'cursor', Applitools::Location

      if driver.frame_chain.same_frame_chain? last_screenshot.frame_chain
        logger.info "Ignoring #{mouse_action} (different_frame)"
        return
      end

      add_mouse_trigger_base(mouse_action, control, cursor)
    end

    public :add_text_trigger, :add_mouse_trigger, :add_mouse_trigger_by_region_and_location

    protected

    def app_environment
      app_env = super
      if app_env.os.nil?
        logger.info 'No OS set, checking for mobile OS...'
        underlying_driver = Applitools::Utils::EyesSeleniumUtils.mobile_device?(driver)
        unless underlying_driver.nil?
          logger.info 'Mobile device detected! Checking device type...'
          if Applitools::Utils::EyesSeleniumUtils.android?(underlying_driver)
            logger.info 'Android detected...'
            platform_name = 'Android'
          elsif Applitools::Utils::EyesSeleniumUtils.ios?(underlying_driver)
            logger.info 'iOS detected...'
            platform_name = 'iOS'
          else
            logger.info 'Unknown device type'
          end
        end

        if platform_name && !platform_name.empty?
          os = platform_name
          platform_version = Applitools::Utils::EyesSeleniumUtils.platform_version(underlying_driver).to_s
          unless platform_version.empty?
            major_version = platform_version.split(/\./).first
            os << " #{major_version}"
          end
          logger.info "Setting OS: #{os}"
          app_env.os = os
        end
      else
        logger.info 'No mobile OS detected.'
      end
      app_env
    end

    def inferred_environment
      return @inferred_environment unless @inferred_environment.nil?

      user_agent = driver.user_agent
      return "useragent: #{user_agent}" if user_agent && !user_agent.empty?

      nil
    end

    def ensure_frame_visible
      original_fc = driver.frame_chain
      return original_fc if original_fc.empty?
      fc = Applitools::Selenium::FrameChain.new other: original_fc
      until fc.empty?
        driver.switch_to.parent_frame
        position_provider.position = fc.pop.location
      end
      driver.switch_to.frames(frame_chain: original_fc)
      original_fc
    end

    def reset_frames_scroll_position(original_fc)
      return original_fc if original_fc.empty?
      fc = Applitools::Selenium::FrameChain.new other: original_fc
      until fc.empty?
        driver.switch_to.parent_frame
        position_provider.position = fc.pop.parent_scroll_position
      end
      driver.switch_to.frames(frame_chain: original_fc)
      original_fc
    end

    class << self
      def position_provider(stitch_mode, driver, disable_horizontal = false, disable_vertical = false,
        explicit_entire_size = nil)

        max_width = nil
        max_height = nil
        unless explicit_entire_size.nil?
          max_width = explicit_entire_size.width
          max_height = explicit_entire_size.height
        end
        case stitch_mode
        when Applitools::Selenium::StitchModes::SCROLL
          Applitools::Selenium::ScrollPositionProvider.new(driver, disable_horizontal, disable_vertical,
            max_width, max_height)
        when Applitools::Selenium::StitchModes::CSS
          Applitools::Selenium::CssTranslatePositionProvider.new(driver, disable_horizontal, disable_vertical,
            max_width, max_height)
        end
      end
    end
  end
end
