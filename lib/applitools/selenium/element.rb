module Applitools::Selenium
  class Element < SimpleDelegator
    JS_GET_COMPUTED_STYLE_FORMATTED_STR = <<-JS.freeze
       var elem = arguments[0];
       var styleProp = '%s';
       if (window.getComputedStyle) {
       return window.getComputedStyle(elem, null)
       .getPropertyValue(styleProp);
       } else if (elem.currentStyle) {
       return elem.currentStyle[styleProp];
       } else {
       return null;
       };
    JS

    JS_GET_SCROLL_LEFT = 'return arguments[0].scrollLeft;'.freeze
    JS_GET_SCROLL_TOP = 'return arguments[0].scrollTop;'.freeze
    JS_GET_SCROLL_WIDTH = 'return arguments[0].scrollWidth;'.freeze
    JS_GET_SCROLL_HEIGHT = 'return arguments[0].scrollHeight;'.freeze

    JS_SCROLL_TO_FORMATTED_STR = <<-JS.freeze
      arguments[0].scrollLeft = %d;
      arguments[0].scrollTop = %d;
    JS

    JS_GET_OVERFLOW = 'return arguments[0].style.overflow;'.freeze
    JS_SET_OVERFLOW_FORMATTED_STR = "arguments[0].style.overflow = '%s'".freeze

    TRACE_PREFIX = 'EyesWebElement'.freeze

    # def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=

    # Initialize class instance.
    #
    # @param [Applitools::Selenium::Driver] driver The wrapped Selenium driver instance.
    # @param [Applitools::Selenium::Element] element The wrapped Selenium element instance.
    def initialize(driver, element)
      super(element)

      @driver = driver
    end

    def web_element
      @web_element ||= __getobj__
    end

    protected :web_element

    def click
      @driver.add_mouse_trigger(Applitools::MouseTrigger::MOUSE_ACTION[:click], self)
      # logger.info "click(#{bounds})";
      web_element.click
    end

    def inspect
      TRACE_PREFIX + web_element.inspect
    end

    def ==(other)
      if other.is_a? self.class
        super other.web_element
      else
        super other
      end
    end

    alias eql? ==

    # Types content into text box.
    #
    # @param [Array] *args The arguments.
    # @option *args [String] The content to type.
    def send_keys(*args)
      Selenium::WebDriver::Keys.encode(args).each do |key|
        @driver.add_text_trigger(self, key.to_s)
      end
      web_element.send_keys(*args)
    end
    alias send_key send_keys

    # Gets the bounds of the element.
    #
    # @return [Applitools::Base::Region] An instance of the region.
    def bounds
      point = location
      left = point.x
      top = point.y
      width = 0
      height = 0

      begin
        dimension = size
        width = dimension.width
        height = dimension.height
      rescue => e
        # Not supported on all platforms.
        Applitools::EyesLogger.error("Failed extracting size using JavaScript: (#{e.message})")
      end

      if left < 0
        width = [0, width + left].max
        left = 0
      end

      if top < 0
        height = [0, height + top].max
        top = 0
      end

      Applitools::Base::Region.new(left, top, width, height)
    end

    def find_element(*args)
      self.class.new driver, super
    end

    def find_elements(*args)
      super(*args).map { |e| self.class.new driver, e }
    end

    def overflow
      driver.execute_script(JS_GET_OVERFLOW, __getobj__).to_s
    end

    def overflow=(overflow)
      driver.execute_script(JS_SET_OVERFLOW_FORMATTED_STR % overflow, self)
    end

    def computed_style(prop_style)
      driver.execute_script(JS_GET_COMPUTED_STYLE_FORMATTED_STR % prop_style, self).to_s
    end

    def computed_style_integer(prop_style)
      computed_style(prop_style).gsub(/px/, '').to_i.round
    end

    def border_left_width
      computed_style_integer(:'border-left-width')
    end

    def border_top_width
      computed_style_integer(:'border-top-width')
    end

    def border_right_width
      computed_style_integer(:'border-right-width')
    end

    def border_bottom_width
      computed_style_integer(:'border-bottom-width')
    end

    def padding_left_width
      computed_style_integer(:'padding-left')
    end

    def padding_right_width
      computed_style_integer(:'padding-right')
    end

    def padding_top_width
      computed_style_integer(:'padding-top')
    end

    def padding_bottom_width
      computed_style_integer(:'padding-bottom')
    end

    def scroll_left
      Integer driver.execute_script(JS_GET_SCROLL_LEFT, self).to_s
    end

    def scroll_top
      Integer driver.execute_script(JS_GET_SCROLL_TOP, self).to_s
    end

    def scroll_width
      Integer driver.execute_script(JS_GET_SCROLL_WIDTH, self).to_s
    end

    def scroll_height
      Integer driver.execute_script(JS_GET_SCROLL_HEIGHT, self).to_s
    end

    def scroll_to(location)
      driver.execute_script format(JS_SCROLL_TO_FORMATTED_STR, location.x, location.y), self
    end

    def to_hash
      {
        left: location.x.to_i,
        top: location.y.to_i,
        width: size.width.to_i,
        height: size.height.to_i
      }
    end

    private

    attr_reader :driver
  end
end
