# frozen_string_literal: true

require_relative '../lib/eyes_selenium'
require 'logger'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

eyes = Applitools::Selenium::Eyes.new
eyes.force_full_page_screenshot = true
eyes.api_key = ENV['APPLITOOLS_API_KEY']
eyes.log_handler = Logger.new(STDOUT)
eyes.match_level = Applitools::MATCH_LEVEL[:layout]
eyes.send_dom = true
eyes.use_dom = true
eyes.enable_patterns = true

begin
  web_driver = Selenium::WebDriver.for :chrome
  eyes.test(
    app_name: 'DOM Capture 777',
    test_name: 'Applitools DomCapture test BM 15',
    viewport_size: { width: 800, height: 601 },
    driver: web_driver
  ) do |driver|
    driver.get 'http://localhost:3000'
    eyes.check_window('initial')
  end
ensure
  web_driver.quit
end

# begin
#   web_driver = Selenium::WebDriver.for(
#     :remote, url: 'https://ondemand.saucelabs.com/wd/hub',
#     desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome.merge!(
#       username: ENV['SAUCE_USERNAME'], accesskey: ENV['SAUCE_ACCESS_KEY']
#     )
#   )
#   eyes.test(
#     app_name: 'DOM Capture Sauce',
#     test_name: 'Applitools DomCapture test',
#     viewport_size: { width: 800, height: 600 },
#     driver: web_driver
#   ) do |driver|
#     driver.get 'https://nikita-andreev.github.io/applitools/dom_capture.html?aaa'
#     eyes.check_window('initial')
#   end
# ensure
#   web_driver.quit if web_driver
# end
