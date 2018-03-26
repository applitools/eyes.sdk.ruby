# frozen_string_literal: true

require 'spec_helper'
require_relative 'test_api'

RSpec.describe 'TestClassicApi_Chrome', :integration => true, :browser => :chrome, :api => :classic do
  let(:test_suit_name) { 'Eyes Selenium SDK - Classic API - ForceFPS' }
  let(:tested_page_url) { 'http://applitools.github.io/demo/TestPages/FramesTestPage/' }
  let(:force_fullpage_screenshot) { true }
  let(:caps) do
    Selenium::WebDriver::Remote::Capabilities.chrome(
      'chromeOptions' => {
        'args' => ['disable-infobars', 'headless']
      }
    )
  end
  include_context 'test classic API'
end
