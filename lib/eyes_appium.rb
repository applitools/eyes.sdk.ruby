# frozen_string_literal: false

require 'eyes_selenium'
require 'appium_lib'

Applitools.require_dir('appium')

if defined? Appium::Driver
  Appium::Core::Base::Driver.class_eval do
    def driver_for_eyes(eyes)
      if defined? Appium
        if driver.public_methods(false).none? {|k| Applitools::Appium::Driver::AppiumLib.method_defined?(k) }
          Appium.promote_appium_methods(Applitools::Appium::Driver::AppiumLib)
        end
      end
      Applitools::Appium::Driver.new(eyes, driver: self, is_mobile_device: true)
    end
  end

  Appium::Driver.class_eval do
    def driver_for_eyes(eyes)
      if driver.public_methods(false).none? {|k| Applitools::Appium::Driver::AppiumLib.method_defined?(k) }
        Appium.promote_appium_methods(Applitools::Appium::Driver::AppiumLib, self)
      end
      started_driver = self.http_client ? self.driver : self.start_driver
      Applitools::Appium::Driver.new(eyes, driver: started_driver, is_mobile_device: true)
    end
  end
end

