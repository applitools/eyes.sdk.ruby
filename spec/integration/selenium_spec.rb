# frozen_string_literal: true
require 'spec_helper'
require_relative 'test_classic_api_v1'
require_relative 'test_fluent_api_v1'
require_relative 'test_fluent_api_frames_v1'
require_relative 'test_page_with_header'
require_relative 'test_simple_cases_v1'
require_relative 'test_special_cases_v1'
require_relative 'test_duplicates_v1'
require 'pry'

RSpec.describe 'Selenium Browser Tests' do
  after(:context) do
    puts $vg_runner.get_all_test_results if $vg_runner
    puts $classic_runner.get_all_test_results if $classic_runner
  end

  context 'Eyes Selenium SDK - Classic API', selenium: true do
    include_examples 'Classic API'
  end

  context 'Eyes Selenium SDK - Classic API', selenium: true, scroll: true do
    include_examples 'Classic API'
  end

  context 'Eyes Selenium SDK - Classic API', visual_grid: true do
    include_examples 'Classic API'
  end

  context 'Eyes Selenium SDK - Fluent API', selenium: true do
    include_examples 'Fluent API'
  end

  context 'Eyes Selenium SDK - Fluent API', selenium: true, scroll: true do
    include_examples 'Fluent API'
  end

  context 'Eyes Selenium SDK - Fluent API', visual_grid: true do
    include_examples 'Fluent API'
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

  context 'Eyes Selenium SDK - Duplicates', selenium: true do
    include_examples 'Eyes Selenium SDK - Duplicates'
  end

  context 'Eyes Selenium SDK - Duplicates', selenium: true, scroll: true do
    include_examples 'Eyes Selenium SDK - Duplicates'
  end

  context 'Eyes Selenium SDK - Duplicates', visual_grid: true do
    include_examples 'Eyes Selenium SDK - Duplicates'
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

  context 'Eyes Selenium SDK - Simple Test Cases', selenium: true do
    include_examples 'Eyes Selenium SDK - Simple Test Cases'
  end

  context 'Eyes Selenium SDK - Simple Test Cases', selenium: true, scroll: true do
    include_examples 'Eyes Selenium SDK - Simple Test Cases'
  end

  context 'Eyes Selenium SDK - Simple Test Cases', visual_grid: true do
    include_examples 'Eyes Selenium SDK - Simple Test Cases'
  end

  context 'Eyes Selenium SDK - Special Cases', selenium: true do
    include_examples 'Eyes Selenium SDK - Special Cases'
  end

  context 'Eyes Selenium SDK - Special Cases', selenium: true, scroll: true do
    include_examples 'Eyes Selenium SDK - Special Cases'
  end

  context 'Eyes Selenium SDK - Special Cases', visual_grid: true do
    include_examples 'Eyes Selenium SDK - Special Cases'
  end
end
