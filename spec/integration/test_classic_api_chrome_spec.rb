require 'spec_helper'
require_relative 'test_api'

RSpec.describe 'TestClassicApi_Chrome', integration: true do
  let(:test_suit_name) { 'Eyes Selenium SDK - Classic API' }
  let(:tested_page_url) { 'http://applitools.github.io/demo/TestPages/FramesTestPage/' }
  let(:force_fullpage_screenshot) { false }
  let(:caps) {
    Selenium::WebDriver::Remote::Capabilities.chrome(
      "chromeOptions" => {
          "args" => [ "disable-infobars", "headless" ]
      }
    )
  }
  include_context 'test classic API'
end