# frozen_string_literal: true

module Applitools::Appium
  class Driver < Applitools::Selenium::Driver
    def initialize(eyes, options)
      super(eyes, options)
    end
    module AppiumLib
      extend self
    end
  end
end
