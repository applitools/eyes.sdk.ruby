# frozen_string_literal: true

require 'spec_helper'
require_relative 'old_tests/b'
require_relative 'old_tests/firefox_settings'

RSpec.describe 'TestFluentApi_Firefox', :integration => true, :browser => :firefox, :api => :fluent do
  let(:test_suit_name) { 'Eyes Selenium SDK - Fluent API' }
  let(:force_fullpage_screenshot) { false }
  include_context 'firefox settings'
  include_context 'test fluent API'
end
