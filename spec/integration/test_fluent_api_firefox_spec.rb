require 'spec_helper'
require_relative 'test_api'

RSpec.describe 'TestFluentApi_Chrome', integration: true do
  let(:test_suit_name) { 'Eyes Selenium SDK - Fluent API' }
  let(:tested_page_url) { 'http://applitools.github.io/demo/TestPages/FramesTestPage/' }
  let(:force_fullpage_screenshot) { false }
  let(:caps) { Selenium::WebDriver::Remote::Capabilities.firefox }
  include_context 'test fluent API'
end