# frozen_string_literal: true
require_relative 'test_fluent_api_frames_v1'
RSpec.describe 'Fluent API frames', report_me: true do
  def test_reporting_group
    'selenium'
  end

  context 'Eyes Selenium SDK - Fluent API', selenium: true do
    include_examples 'Fluent API Frames'
  end

  context 'Eyes Selenium SDK - Fluent API', selenium: true, scroll: true do
    include_examples 'Fluent API Frames'
  end

  context 'Eyes Selenium SDK - Fluent API', visual_grid: true do
    include_examples 'Fluent API Frames'
  end
end
