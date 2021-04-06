# frozen_string_literal: false

module Applitools::Appium
  module Init20
    extend self
    def init
      Applitools::Appium::Utils.module_eval do
        include Applitools::Utils::EyesSeleniumUtils
        extend Applitools::Utils::EyesSeleniumUtils
        extend self
      end
    end
  end
end
