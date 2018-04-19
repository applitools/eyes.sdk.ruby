# frozen_string_literal: false

module Applitools::Utils
  module EyesSeleniumUtils
    extend self

    # @!visibility private
    JS_GET_VIEWPORT_SIZE = <<-JS.freeze
       return (function() {
         var height = undefined;
         var width = undefined;
         if (window.innerHeight) {height = window.innerHeight;}
         else if (document.documentElement && document.documentElement.clientHeight)
         {height = document.documentElement.clientHeight;}
         else { var b = document.getElementsByTagName('body')[0];
            if (b.clientHeight) {height = b.clientHeight;}
         };

         if (window.innerWidth) {width = window.innerWidth;}
         else if (document.documentElement && document.documentElement.clientWidth)
         {width = document.documentElement.clientWidth;}
         else { var b = document.getElementsByTagName('body')[0];
            if (b.clientWidth) {width = b.clientWidth;}
         };
         return [width, height];
         }());
    JS

    # @!visibility private
    JS_GET_USER_AGENT = <<-JS.freeze
      return navigator.userAgent;
    JS

    # @!visibility private
    JS_GET_DEVICE_PIXEL_RATIO = <<-JS.freeze
      return window.devicePixelRatio;
    JS

    # @!visibility private
    JS_GET_PAGE_METRICS = <<-JS.freeze
      return {
        scrollWidth: document.documentElement.scrollWidth,
        bodyScrollWidth: document.body.scrollWidth,
        clientHeight: document.documentElement.clientHeight,
        bodyClientHeight: document.body.clientHeight,
        scrollHeight: document.documentElement.scrollHeight,
        bodyScrollHeight: document.body.scrollHeight
      };
    JS

    # @!visibility private
    JS_GET_CONTENT_ENTIRE_SIZE = <<-JS.freeze
        var scrollWidth = document.documentElement.scrollWidth;
        var bodyScrollWidth = document.body.scrollWidth;
        var totalWidth = Math.max(scrollWidth, bodyScrollWidth);
        var clientHeight = document.documentElement.clientHeight;
        var bodyClientHeight = document.body.clientHeight;
        var scrollHeight = document.documentElement.scrollHeight;
        var bodyScrollHeight = document.body.scrollHeight;
        var maxDocElementHeight = Math.max(clientHeight, scrollHeight);
        var maxBodyHeight = Math.max(bodyClientHeight, bodyScrollHeight);
        var totalHeight = Math.max(maxDocElementHeight, maxBodyHeight);
        return [totalWidth, totalHeight];
    JS

    # @!visibility private
    JS_GET_CURRENT_SCROLL_POSITION = <<-JS.freeze
      return (function() {
        var doc = document.documentElement;
        var x = (window.scrollX || window.pageXOffset || doc.scrollLeft) - (doc.clientLeft || 0);
        var y = (window.scrollY || window.pageYOffset || doc.scrollTop)  - (doc.clientTop || 0);

        return {left: parseInt(x, 10) || 0, top: parseInt(y, 10) || 0};
      }());
    JS

    # @!visibility private
    JS_SCROLL_TO = <<-JS.freeze
      window.scrollTo(%{left}, %{top});
    JS

    # IMPORTANT: Notice there's a major difference between scrollWidth
    # and scrollHeight. While scrollWidth is the maximum between an
    # element's width and its content width, scrollHeight might be
    # smaller (!) than the clientHeight, which is why we take the
    # maximum between them.

    # @!visibility private
    JS_COMPUTE_CONTENT_ENTIRE_SIZE = <<-JS.freeze
      var scrollWidth = document.documentElement.scrollWidth;
      var bodyScrollWidth = document.body.scrollWidth;
      var totalWidth = Math.max(scrollWidth, bodyScrollWidth);
      var clientHeight = document.documentElement.clientHeight;
      var bodyClientHeight = document.body.clientHeight;
      var scrollHeight = document.documentElement.scrollHeight;
      var bodyScrollHeight = document.body.scrollHeight;
      var maxDocElementHeight = Math.max(clientHeight, scrollHeight);
      var maxBodyHeight = Math.max(bodyClientHeight, bodyScrollHeight);
      var totalHeight = Math.max(maxDocElementHeight, maxBodyHeight);
    JS

    # @!visibility private
    JS_RETURN_CONTENT_ENTIRE_SIZE = <<-JS.freeze
      #{JS_COMPUTE_CONTENT_ENTIRE_SIZE}; return [totalWidth, totalHeight];
    JS

    # @!visibility private
    JS_SCROLL_TO_BOTTOM_RIGHT = <<-JS.freeze
      #{JS_COMPUTE_CONTENT_ENTIRE_SIZE}; window.scrollTo(totalWidth, totalHeight);
    JS

    # @!visibility private
    JS_GET_CURRENT_TRANSFORM = <<-JS.freeze
      return document.body.style.transform;
    JS

    # @!visibility private
    JS_SET_TRANSFORM = <<-JS.freeze
      return (function() {
        var originalTransform = document.body.style.transform;
        document.body.style.transform = '%{transform}';
        return originalTransform;
      }());
    JS

    # @!visibility private
    JS_SET_OVERFLOW = <<-JS.freeze
      return (function() {
        var origOF = document.documentElement.style.overflow;
        document.documentElement.style.overflow = '%{overflow}';
        return origOF;
      }());
    JS

    # JS_GET_TRANSFORM_VALUE = <<-JS.freeze
    #   document.documentElement.style['%{key}']
    # JS
    #
    # JS_SET_TRANSFORM_VALUE = <<-JS.freeze
    #   document.documentElement.style['%{key}'] = '%{value}'
    # JS

    JS_GET_TRANSFORM_VALUE = <<-JS.freeze
      %{element}.style['%{key}']
    JS

    JS_SET_TRANSFORM_VALUE = <<-JS.freeze
      %{element}.style['%{key}'] = '%{value}'
    JS

    JS_TRANSFORM_KEYS = ['transform', '-webkit-transform'].freeze

    # @!visibility private
    OVERFLOW_HIDDEN = 'hidden'.freeze

    BROWSER_SIZE_CALCULATION_RETRIES = 3

    # Number of attemts to set browser size
    VERIFY_RETRIES = 3

    # A time delay (in seconds) before next attempt to set browser size
    VERIFY_SLEEP_PERIOD = 1

    # Maximum different (in pixels) between calculated browser size and real browser size when it tries to achieve
    # target size incrementally
    MAX_DIFF = 3

    # true if test is running on mobile device
    def mobile_device?
      return nil unless defined?(Appium::Driver)
      return $driver if $driver && $driver.is_a?(Appium::Driver)
    end

    # true if test is running on Android device
    def android?(driver)
      driver.respond_to?(:appium_device) && driver.appium_device == :android
    end

    # true if test is running on iOS device
    def ios?(driver)
      driver.respond_to?(:appium_device) && driver.appium_device == :ios
    end

    # @param [Applitools::Selenium::Driver] driver
    def platform_version(driver)
      driver.respond_to?(:caps) && driver.caps[:platformVersion]
    end

    # @param [Applitools::Selenium::Driver] executor
    # @return [Applitools::Location] {Applitools::Location} instance which indicates current scroll
    #   position
    def current_scroll_position(executor)
      position = Applitools::Utils.symbolize_keys executor.execute_script(JS_GET_CURRENT_SCROLL_POSITION).to_hash
      Applitools::Location.new position[:left], position[:top]
    end

    # scrolls browser to position specified by point.
    # @param [Applitools::Selenium::Driver] executor
    # @param [Applitools::Location] point position to scroll to. It can be any object,
    #   having left and top properties
    def scroll_to(executor, point)
      with_timeout(0.25) { executor.execute_script(JS_SCROLL_TO % { left: point.left, top: point.top }) }
    end

    # @param [Applitools::Selenium::Driver] executor
    def extract_viewport_size(executor)
      Applitools::EyesLogger.debug 'extract_viewport_size()'

      begin
        width, height = executor.execute_script(JS_GET_VIEWPORT_SIZE)
        result = Applitools::RectangleSize.from_any_argument width: width, height: height
        Applitools::EyesLogger.debug "Viewport size is #{result}."
        return result
      rescue => e
        Applitools::EyesLogger.error "Failed extracting viewport size using JavaScript: (#{e.message})"
      end

      Applitools::EyesLogger.info 'Using window size as viewport size.'

      width, height = executor.manage.window.size.to_a
      width, height = height, width if executor.landscape_orientation? && height > width

      result = Applitools::RectangleSize.new width, height
      Applitools::EyesLogger.debug "Viewport size is #{result}."
      result
    end

    # @param [Applitools::Selenium::Driver] executor
    def entire_page_size(executor)
      return Applitools::MOCK_ENTIRE_SIZE if defined?(Applitools::MOCK_ENTIRE_SIZE)
      metrics = page_metrics(executor)
      max_document_element_height = [metrics[:client_height], metrics[:scroll_height]].max
      max_body_height = [metrics[:body_client_height], metrics[:body_scroll_height]].max

      total_width = [metrics[:scroll_width], metrics[:body_scroll_width]].max
      total_height = [max_document_element_height, max_body_height].max

      Applitools::RectangleSize.new(total_width, total_height)
    end

    def current_frame_content_entire_size(executor)
      return Applitools::MOCK_ENTIRE_SIZE if defined?(Applitools::MOCK_ENTIRE_SIZE)
      dimensions = executor.execute_script(JS_GET_CONTENT_ENTIRE_SIZE)
      Applitools::RectangleSize.new(dimensions.first.to_i, dimensions.last.to_i)
    rescue
      raise Applitools::EyesDriverOperationException.new 'Failed to extract entire size!'
    end

    def current_transforms(executor)
      transform_script = JS_TRANSFORM_KEYS.map do |tk|
        "'#{tk}': #{JS_GET_TRANSFORM_VALUE % { element: 'document.documentElement', key: tk }}"
      end.join(', ')
      script = "return { #{transform_script} };"
      executor.execute_script(script)
    end

    def set_current_transforms(executor, transform)
      value = {}
      JS_TRANSFORM_KEYS.map { |tk| value[tk] = transform }
      set_transforms(executor, value)
    end

    def set_transforms(executor, value)
      script = value.keys.map do |k|
        JS_SET_TRANSFORM_VALUE % { element: 'document.documentElement', key: k, value: value[k] }
      end.join('; ')
      executor.execute_script(script)
    end

    def set_element_transforms(executor, element, transform)
      value = {}
      JS_TRANSFORM_KEYS.map { |tk| value[tk] = transform }
      script = value.keys.map do |k|
        JS_SET_TRANSFORM_VALUE % { element: 'arguments[0]', key: k, value: value[k] }
      end.join('; ')
      executor.execute_script(script, element)
    end

    def current_element_transforms(executor, element)
      transform_script = JS_TRANSFORM_KEYS.map do |tk|
        "'#{tk}': #{JS_GET_TRANSFORM_VALUE % { element: 'arguments[0]', key: tk }}"
      end.join(', ')
      script = "return { #{transform_script} };"
      executor.execute_script(script, element)
    end

    def translate_to(executor, location)
      set_current_transforms(executor, "translate(#{-location.x}px, #{-location.y}px)")
    end

    def element_translate_to(executor, element, location)
      set_element_transforms(executor, element, "translate(#{location.x}px, #{location.y}px)")
    end

    # @param [Applitools::Selenium::Driver] executor
    def device_pixel_ratio(executor)
      executor.execute_script(JS_GET_DEVICE_PIXEL_RATIO)
    end

    # @param [Applitools::Selenium::Driver] executor
    def page_metrics(executor)
      Applitools::Utils.underscore_hash_keys(executor.execute_script(JS_GET_PAGE_METRICS))
    end

    # @param [Applitools::Selenium::Driver] executor
    def hide_scrollbars(executor)
      set_overflow executor, OVERFLOW_HIDDEN
    end

    # @param [Applitools::Selenium::Driver] executor
    def set_overflow(executor, overflow)
      with_timeout(0.1) { executor.execute_script(JS_SET_OVERFLOW % { overflow: overflow }) }
    end

    # @param [Applitools::Selenium::Driver] executor
    # @param [Applitools::RectangleSize] viewport_size
    def set_viewport_size(executor, viewport_size)
      Applitools::ArgumentGuard.not_nil 'viewport_size', viewport_size
      Applitools::EyesLogger.info "Set viewport size #{viewport_size}"

      required_size = Applitools::RectangleSize.from_any_argument viewport_size
      actual_viewport_size = Applitools::RectangleSize.from_any_argument(extract_viewport_size(executor))

      Applitools::EyesLogger.info "Initial viewport size: #{actual_viewport_size}"

      if actual_viewport_size == required_size
        Applitools::EyesLogger.info 'Required size is already set.'
        return
      end

      # Before resizing the window, set its position to the upper left corner (otherwise, there might not be enough
      # "space" below/next to it and the operation won't be successful).
      begin
        executor.manage.window.position = Selenium::WebDriver::Point.new(0, 0)
      rescue Selenium::WebDriver::Error::UnsupportedOperationError => e
        Applitools::EyesLogger.error e.message << '\n Continue...'
      end

      set_browser_size_by_viewport_size(executor, actual_viewport_size, required_size)

      actual_viewport_size = extract_viewport_size(executor)
      return if actual_viewport_size == required_size

      # Additional attempt. This Solves the "maximized browser" bug
      # (border size for maximized browser sometimes different than
      # non-maximized, so the original browser size calculation is
      # wrong).

      Applitools::EyesLogger.info 'Trying workaround for maximization...'

      set_browser_size_by_viewport_size(executor, actual_viewport_size, required_size)

      actual_viewport_size = extract_viewport_size(executor)
      Applitools::EyesLogger.info "Current viewport size: #{actual_viewport_size}"
      return if actual_viewport_size == required_size

      width_diff = actual_viewport_size.width - required_size.width
      width_step = width_diff > 0 ? -1 : 1
      height_diff = actual_viewport_size.height - required_size.height
      height_step = height_diff > 0 ? -1 : 1

      browser_size = Applitools::RectangleSize.from_any_argument(executor.manage.window.size)

      current_width_change = 0
      current_height_change = 0

      if width_diff.abs <= MAX_DIFF && height_diff <= MAX_DIFF
        Applitools::EyesLogger.info 'Trying  workaround for zoom...'
        while current_width_change.abs <= width_diff && current_height_change.abs <= height_diff

          current_width_change += width_step if actual_viewport_size.width != required_size.width
          current_height_change += height_step if actual_viewport_size.height != required_size.height

          set_browser_size executor,
            browser_size.dup + Applitools::RectangleSize.new(current_width_change, current_height_change)

          actual_viewport_size = Applitools::RectangleSize.from_any_argument extract_viewport_size(executor)
          Applitools::EyesLogger.info "Current viewport size: #{actual_viewport_size}"
          return if actual_viewport_size == required_size
        end
        Applitools::EyesLogger.error 'Zoom workaround failed.'
      end

      raise Applitools::TestFailedError.new "Failed to set viewport size (#{viewport_size})"
    end

    def set_browser_size(executor, required_size)
      retries_left = VERIFY_RETRIES
      current_size = Applitools::RectangleSize.new(0, 0)
      while retries_left > 0 && current_size != required_size
        Applitools::EyesLogger.info "Trying to set browser size to #{required_size}"
        executor.manage.window.size = required_size
        sleep VERIFY_SLEEP_PERIOD
        current_size = Applitools::RectangleSize.from_any_argument(executor.manage.window.size)
        Applitools::EyesLogger.info "Current browser size: #{required_size}"
        retries_left -= 1
      end
      current_size == required_size
    end

    def set_browser_size_by_viewport_size(executor, actual_viewport_size, required_size)
      browser_size = executor.manage.window.size
      if browser_size.width.nil? || browser_size.height.nil?
        raise(
          Applitools::EyesError,
          'driver.manage.window.size returned nil values. ' \
          'Please ensure that you use the latest version of browser and its driver!'
        )
      end
      browser_size = Applitools::RectangleSize.from_any_argument(browser_size)
      Applitools::EyesLogger.info "Current browser size: #{browser_size}"
      required_browser_size = browser_size + required_size - actual_viewport_size
      set_browser_size(executor, required_browser_size)
    end

    def scroll_to_bottom_right(executor)
      executor.execute_script(JS_SCROLL_TO_BOTTOM_RIGHT)
    end

    private

    def with_timeout(timeout, &_block)
      raise 'You have to pass block to method with_timeout' unless block_given?
      yield.tap { sleep timeout }
    end
  end
end
