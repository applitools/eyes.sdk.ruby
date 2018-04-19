# frozen_string_literal: true

require 'spec_helper'
require_relative 'test_api'
require_relative 'chrome_settings'

RSpec.describe 'TestClassicApi_Chrome', :integration => true, :browser => :crome, :api => :none do
  let(:test_suit_name) { 'Eyes Selenium SDK - Special Cases - ForceFPS' }
  let(:force_fullpage_screenshot) { true }
  include_context 'chrome settings'
  include_context 'test special cases'
  before do
    eyes.hide_scrollbars = true
  end
end
