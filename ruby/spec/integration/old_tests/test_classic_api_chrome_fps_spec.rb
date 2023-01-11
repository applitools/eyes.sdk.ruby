# frozen_string_literal: true

require 'spec_helper'
require_relative 'test_api'
require_relative 'old_tests/tings'

RSpec.describe 'TestClassicApi_Chrome', :integration => true, :browser => :chrome, :api => :classic do
  let(:test_suit_name) { 'Eyes Selenium SDK - Classic API - ForceFPS' }
  let(:force_fullpage_screenshot) { true }
  include_context 'chrome settings'
  include_context 'test classic API'
end
