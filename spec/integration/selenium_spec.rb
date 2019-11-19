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
  context 'Classic API', selenium: true do
    include_examples 'Classic API'
  end

  context 'Classic API scroll', selenium: true, scroll: true do
    include_examples 'Classic API'
  end

  context 'Classic API VG', visual_grid: true do
    include_examples 'Classic API'
  end

  context 'Fluent API', selenium: true do
    include_examples 'Fluent API'
    include_examples 'Fluent API Frames'
  end

  context 'Fluent API', selenium: true, scroll: true do
    include_examples 'Fluent API'
    include_examples 'Fluent API Frames'
  end

  context 'Fluent API', visual_grid: true do
    include_examples 'Fluent API'
    include_examples 'Fluent API Frames'
  end

  context 'The rest desctop browser tests', selenium: true do
    include_examples 'Eyes Selenium SDK - Page With Header'
    include_examples 'Eyes Selenium SDK - Simple Test Cases'
    include_examples 'Eyes Selenium SDK - Special Cases'
    include_examples 'Eyes Selenium SDK - Duplicates'
  end

  context 'The rest desctop browser tests', selenium: true, scroll: true do
    include_examples 'Eyes Selenium SDK - Page With Header'
    include_examples 'Eyes Selenium SDK - Simple Test Cases'
    include_examples 'Eyes Selenium SDK - Special Cases'
    include_examples 'Eyes Selenium SDK - Duplicates'
  end

  context 'The rest desctop browser tests', visual_grid: true do
    include_examples 'Eyes Selenium SDK - Page With Header'
    include_examples 'Eyes Selenium SDK - Simple Test Cases'
    include_examples 'Eyes Selenium SDK - Special Cases'
    include_examples 'Eyes Selenium SDK - Duplicates'
  end
end