require 'spec_helper'
require_relative 'test_api'

RSpec.describe 'TestClassicApi_Chrome', integration: true do
  let(:test_suit_name) { 'Eyes Selenium SDK - Special Cases' }
  let(:tested_page_url) { 'http://applitools.github.io/demo/TestPages/WixLikeTestPage/index.html' }
  let(:force_fullpage_screenshot) { false }
  let(:caps) {
    Selenium::WebDriver::Remote::Capabilities.chrome(
        "chromeOptions" => {
            "args" => [ "disable-infobars", "headless" ]
        }
    )
  }
  include_context 'test special cases'
  before do
    eyes.hide_scrollbars = true
  end
end