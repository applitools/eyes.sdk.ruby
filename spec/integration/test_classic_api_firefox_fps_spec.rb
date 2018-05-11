# frozen_string_literal: true

require 'spec_helper'
require_relative 'test_api'
require_relative 'firefox_settings'

RSpec.describe 'TestClassicApi_Firefox', :integration => true, :browser => :firefox, :api => :classic do
  let(:test_suit_name) { 'Eyes Selenium SDK - Classic API - ForceFPS' }
  let(:force_fullpage_screenshot) { true }
  include_context 'firefox settings'
  include_context 'test classic API'
end
