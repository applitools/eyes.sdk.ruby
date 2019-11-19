# frozen_string_literal: true

require 'spec_helper'
require_relative 'old_tests/b'
require_relative 'old_tests/chrome_settings'

RSpec.describe 'TestFluentApi_Chrome', :integration => true, :browser => :chrome, :api => :fluent do
  let(:test_suit_name) { 'Eyes Selenium SDK - Fluent API - ForceFPS' }
  let(:force_fullpage_screenshot) { true }
  include_context 'chrome settings'
  include_context 'test fluent API'
end
