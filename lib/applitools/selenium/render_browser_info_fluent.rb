# frozen_string_literal: true

module Applitools
  module Selenium
    class RenderBrowserInfoFluent
      attr_accessor :browser_info
      def initialize(browser_info)
        self.browser_info = browser_info
      end

      def width(value)
        browser_info.viewport_size.width = value
        self
      end

      def height(value)
        browser_info.viewport_size.height = value
        self
      end

      def type(value)
        browser_info.browser_type = value
        self
      end

      def platform(value)
        browser_info.platform = value
        self
      end

      def size_mode(value)
        browser_info.size_mode = value
        self
      end

      def environment(value)
        browser_info.baseline_env_name = value
        self
      end

      def emulation_info(value)
        browser_info.emulation_info = value
        self
      end
    end
  end
end
