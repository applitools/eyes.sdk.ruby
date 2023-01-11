# frozen_string_literal: true
require_relative 'test_page_with_header'
RSpec.describe 'page with header', report_me: true do
  def test_reporting_group
    'selenium'
  end

  context 'Eyes Selenium SDK - Page With Header', selenium: true do
    include_examples 'Eyes Selenium SDK - Page With Header'
  end

  context 'Eyes Selenium SDK - Page With Header', selenium: true, scroll: true do
    include_examples 'Eyes Selenium SDK - Page With Header'
  end

  context 'Eyes Selenium SDK - Page With Header', visual_grid: true do
    include_examples 'Eyes Selenium SDK - Page With Header'
  end
end
