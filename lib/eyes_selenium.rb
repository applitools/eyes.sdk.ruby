require 'eyes_core'

module Applitools::Selenium
  # @!visibility private
  class << self
    # @!visibility private
    def require_dir(dir)
      Dir[File.join(File.dirname(File.expand_path(__FILE__)), 'applitools', dir, '*.rb')].sort.each do |f|
        require f
      end
    end
  end
end

Applitools::Selenium.require_dir 'selenium'
Applitools::Selenium.require_dir 'poltergeist'

if defined? Selenium::WebDriver::Driver
  Selenium::WebDriver::Driver.class_eval do
    def driver_for_eyes(eyes)
      is_mobile_device = capabilities['platformName'] ? true : false
      Applitools::Selenium::Driver.new(eyes, driver: self, is_mobile_device: is_mobile_device)
    end
  end
end

if defined? Appium::Driver
  Appium::Driver.class_eval do
    def driver_for_eyes(eyes)
      Applitools::Selenium::Driver.new(eyes, driver: driver || start_driver, is_mobile_device: true)
    end
  end
end
