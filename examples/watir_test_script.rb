# frozen_string_literal: true

require 'watir-webdriver'
require_relative '../lib/eyes_selenium'
require 'logger'

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

eyes = Applitools::Selenium::Eyes.new
eyes.api_key = ENV['APPLITOOLS_API_KEY']
eyes.log_handler = Logger.new(STDOUT)

browser = Watir::Browser.new :chrome

begin
  eyes.test(app_name: 'Ruby SDK', test_name: 'Applitools website test', viewport_size: { width: 900, height: 600 },
    driver: browser.driver) do |driver|
    driver.get 'http://www.applitools.com'
    eyes.check_window('initial')
    eyes.check_region(:css, 'a.logo', tag: 'Applitools logo')
  end
ensure
  browser.quit
end
