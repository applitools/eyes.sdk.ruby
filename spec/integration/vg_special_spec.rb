# frozen_string_literal: true
require_relative 'test_double_open_close'
require 'pry'

RSpec.describe 'VG special cases' do
  before(:context) do
    Applitools::EyesLogger.log_handler = Logger.new(STDOUT)
  end
  context 'Eyes Selenium SDK - Visual Grid TestDoubleOpenClose', :runner => :vg do
    include_examples 'Eyes Selenium SDK - Visual Grid TestDoubleOpenClose'
  end

  context 'Eyes Selenium SDK - Visual Grid TestDoubleOpenClose' do
    include_examples 'Eyes Selenium SDK - Visual Grid TestDoubleOpenClose'
  end
end
