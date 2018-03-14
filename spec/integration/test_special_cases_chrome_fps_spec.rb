# frozen_string_literal: true

require 'spec_helper'
require_relative 'test_api'

RSpec.describe 'TestClassicApi_Chrome', integration: true do
  let(:test_suit_name) { 'Eyes Selenium SDK - Special Cases - ForceFPS' }
  let(:tested_page_url) { 'http://applitools.github.io/demo/TestPages/WixLikeTestPage/index.html' }
  let(:force_fullpage_screenshot) { true }
  let(:caps) do
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(
      'chromeOptions' => {
        'args' => ['disable-infobars', 'headless']
      }
    )
    if 'http://ondemand.saucelabs.com/wd/hub'.casecmp(selenium_server_url).zero?
      caps[:username] = ENV['SAUCE_USERNAME']
      caps[:accesskey] = ENV['SAUCE_ACCESS_KEY']
    end
    caps
  end
  include_context 'test special cases'
  before do
    eyes.hide_scrollbars = true
  end
end
