require_relative 'eyes_screenshot'
module Applitools::Selenium
  # @!visibility private
  class EntireElementScreenshot < Applitools::Selenium::EyesScreenshot
    def sub_screenshot(*_args)
      self
    end
  end
end
