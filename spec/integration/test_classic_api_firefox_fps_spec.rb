require 'spec_helper'
require_relative 'test_api'

RSpec.describe 'TestClassicApi_Firefox', integration: true do
  let(:test_suit_name) { 'Eyes Selenium SDK - Classic API - ForceFPS' }
  let(:tested_page_url) { 'http://applitools.github.io/demo/TestPages/FramesTestPage/' }
  let(:force_fullpage_screenshot) { true }
  let(:caps) { Selenium::WebDriver::Remote::Capabilities.firefox }
  include_context 'test classic API'
end