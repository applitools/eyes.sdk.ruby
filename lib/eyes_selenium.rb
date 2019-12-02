# frozen_string_literal: true

require 'eyes_core'

module Applitools
  # @!visibility private
  STITCH_MODE = {
    :scroll => :SCROLL,
    :css => :CSS
  }.freeze

  module Selenium
    extend Applitools::RequireUtils
    class UnsupportedCoordinateType < EyesError; end
    def self.load_dir
      File.dirname(File.expand_path(__FILE__))
    end
  end
end

Applitools::Selenium.require_dir 'selenium/concerns'
Applitools::Selenium.require_dir 'selenium/scripts'
Applitools::Selenium.require_dir 'selenium/visual_grid'
Applitools::Selenium.require_dir 'selenium'
Applitools::Selenium.require_dir 'selenium/dom_capture'
Applitools::Selenium.require_dir 'selenium/css_parser'

if defined? Selenium::WebDriver::Driver
  Selenium::WebDriver::Driver.class_eval do
    def driver_for_eyes(eyes)
      is_mobile_device = capabilities['platformName'] ? true : false
      Applitools::Selenium::Driver.new(eyes, driver: self, is_mobile_device: is_mobile_device)
    end
  end
end
