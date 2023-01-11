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
Applitools::Selenium.require_dir 'selenium'
Applitools::Selenium.require_dir 'selenium/visual_grid'
Applitools::Selenium.require_dir 'selenium/dom_capture'
Applitools::Selenium.require_dir 'selenium/css_parser'

if defined? Selenium::WebDriver::Driver
  Selenium::WebDriver::Driver.class_eval do
    def driver_for_eyes(eyes)
      is_mobile_device = capabilities['platformName'] ? true : false
      Applitools::Selenium::Driver.new(eyes, driver: self, is_mobile_device: is_mobile_device)
    end

    def universal_driver_config
      hidden_server_url = bridge.http.send(:server_url).to_s
      if respond_to?(:session_id)
        {
          serverUrl: hidden_server_url,
          sessionId: session_id,
          capabilities: capabilities.as_json
        }
      else
        {
          serverUrl: hidden_server_url,
          sessionId: bridge.session_id,
          capabilities: capabilities.as_json
        }
      end
    end
  end
end
