# frozen_string_literal: true

require_relative 'capybara' if defined? Capybara
Applitools::Selenium.require_dir 'selenium/sauce'
