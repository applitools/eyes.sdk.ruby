# frozen_string_literal: true

require 'spec_helper'
require_relative 'test_api'

RSpec.describe 'TestFluentApi_Firefox', :integration => true, :browser => :firefox, :api => :fluent do
  let(:test_suit_name) { 'Eyes Selenium SDK - Fluent API - ForceFPS' }
  let(:tested_page_url) { 'http://applitools.github.io/demo/TestPages/FramesTestPage/' }
  let(:force_fullpage_screenshot) { true }
  let(:caps) do
    Selenium::WebDriver::Remote::Capabilities.firefox 'moz:firefoxOptions' => {
      profile: Selenium::WebDriver::Firefox::Profile.new.as_json['zip']
    }
  end
  include_context 'test fluent API'
end
