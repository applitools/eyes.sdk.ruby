# frozen_string_literal: true
require_relative 'test_duplicates_v1'
RSpec.describe 'duplicates', report_me: true do
  def test_reporting_group
    'selenium'
  end

  context 'Eyes Selenium SDK - Duplicates', selenium: true do
    include_examples 'Eyes Selenium SDK - Duplicates'
  end

  context 'Eyes Selenium SDK - Duplicates', selenium: true, scroll: true do
    include_examples 'Eyes Selenium SDK - Duplicates'
  end

  context 'Eyes Selenium SDK - Duplicates', visual_grid: true, nsa: true do
    include_examples 'Eyes Selenium SDK - Duplicates'
  end
end
