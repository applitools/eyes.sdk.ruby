# frozen_string_literal: true

require 'eyes_core'
require 'appium_lib'

module Applitools
  # @!visibility private
  # STITCH_MODE = {
  #   :scroll => :SCROLL,
  #   :css => :CSS
  # }.freeze

  module Selenium
    extend Applitools::RequireUtils
    # class UnsupportedCoordinateType < EyesError; end
    def self.load_dir
      File.dirname(File.expand_path(__FILE__))
    end
  end
end

Applitools::Selenium.require_dir 'selenium/concerns'
# Applitools::Selenium.require_dir 'selenium/scripts'
Applitools::Selenium.require_dir 'selenium'
# Applitools::Selenium.require_dir 'selenium/visual_grid'
# Applitools::Selenium.require_dir 'selenium/dom_capture'
# Applitools::Selenium.require_dir 'selenium/css_parser'
Applitools.require_dir 'appium'

# if defined? Selenium::WebDriver::Driver
#   Selenium::WebDriver::Driver.class_eval do
#     def driver_for_eyes(eyes)
#       is_mobile_device = capabilities['platformName'] ? true : false
#       Applitools::Selenium::Driver.new(eyes, driver: self, is_mobile_device: is_mobile_device)
#     end
#   end
# end

# if defined? Appium::Driver
#   Appium::Core::Base::Driver.class_eval do
#     def driver_for_eyes(eyes)
#       if defined? Appium
#         Appium.promote_appium_methods(Applitools::Appium::Driver::AppiumLib)
#       end
#       Applitools::Appium::Driver.new(eyes, driver: self, is_mobile_device: true)
#     end
#   end
#
#   Appium::Driver.class_eval do
#     def driver_for_eyes(eyes)
#       Appium.promote_appium_methods(Applitools::Appium::Driver::AppiumLib, self)
#       started_driver = self.http_client ? self.driver : self.start_driver
#       Applitools::Appium::Driver.new(eyes, driver: started_driver, is_mobile_device: true)
#     end
#   end
# end

