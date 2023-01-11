# frozen_string_literal: true

require 'eyes_selenium'
require 'capybara'

module Applitools
  module Selenium
    module Capybara
      extend Applitools::RequireUtils
      def self.load_dir
        File.dirname(File.expand_path(__FILE__))
      end
    end
  end
end

Applitools::Selenium::Capybara.require_dir 'capybara'

module Applitools
  extend Applitools::Selenium::Capybara::CapybaraSettings
  register_capybara_driver
end
