# frozen_string_literal: false

module Applitools::Appium
  module Utils
    include Applitools::Utils::EyesSeleniumUtils
    extend self

    # true if test is running on mobile device
    def mobile_device?(driver)
      defined?(Appium::Driver) &&
          defined?(Applitools::Appium::Driver::AppiumLib) &&
          Applitools::Appium::Driver::AppiumLib
    end

    # true if test is running on Android device
    def android?(driver)
      driver.respond_to?(:device_is_android?) && driver.device_is_android?
    end

    # true if test is running on iOS device
    def ios?(driver)
      driver.respond_to?(:device_is_ios?) && driver.device_is_ios?
    end

    # @param [Applitools::Selenium::Driver] driver
    def platform_version(driver)
      driver.respond_to?(:platform_version) && driver.platform_version
    end

    # @param [Applitools::Selenium::Driver] executor
    def device_pixel_ratio(executor)
      session_info = session_capabilities(executor)
      return session_info['pixelRatio'].to_f if session_info['pixelRatio']
      1
    end

    def status_bar_height(executor)
      session_info = session_capabilities(executor)
      return session_info['statBarHeight'].to_i if session_info['statBarHeight']
      0
    end

    def viewport_rect(executor)
      session_info = session_capabilities(executor)
      return session_info['viewportRect'] if session_info['viewportRect']
      {
        'left' => 0,
        'top' => 0,
        'width' => 0,
        'height' => 0
      }
    end

    def session_capabilities(executor)
       executor.session_capabilities if executor.respond_to? :session_capabilities
    end

    def current_scroll_position(driver)
      super
    rescue
      Applitools::Location::TOP_LEFT
    end
  end
end
