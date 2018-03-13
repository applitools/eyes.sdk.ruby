# frozen_string_literal: true

require_relative '../lib/eyes_selenium'
require 'logger'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

eyes = Applitools::Selenium::Eyes.new
eyes.api_key = ENV['APPLITOOLS_API_KEY']
eyes.log_handler = Logger.new(STDOUT)
eyes.match_level = Applitools::MATCH_LEVEL[:layout]

begin
  web_driver = Selenium::WebDriver.for :chrome
  eyes.test(
    app_name: 'Ruby SDK',
    test_name: 'Applitools website test',
    viewport_size: { width: 800, height: 600 },
    driver: web_driver
  ) do |driver|
    driver.get 'http://www.applitools.com'
    eyes.check_window('initial')
    eyes.check_region(:css, 'a.logo', tag: 'Applitools logo')
  end
ensure
  web_driver.quit
end
