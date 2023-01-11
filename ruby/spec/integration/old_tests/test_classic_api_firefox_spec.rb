# frozen_string_literal: true

require 'spec_helper'
require_relative 'test_api'
require_relative 'old_tests/ttings'

RSpec.describe 'TestClassicApi_Firefox', :integration => true, :browser => :firefox, :api => :classic do
  let(:test_suit_name) { 'Eyes Selenium SDK - Classic API' }
  let(:force_fullpage_screenshot) { false }
  include_context 'firefox settings'
  include_context 'test classic API'
end
