# frozen_string_literal: true

require 'spec_helper'
require_relative 'test_api'
require_relative 'chrome_settings'

RSpec.describe 'TestFluentApi_Chrome', :integration => true, :browser => :chrome, :api => :fluent do
  let(:test_suit_name) { 'Eyes Selenium SDK - Fluent API' }
  let(:force_fullpage_screenshot) { false }
  include_context 'chrome settings'
  include_context 'test fluent API'
end
