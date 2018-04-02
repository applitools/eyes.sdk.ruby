require_relative 'eyes_screenshot'
module Applitools::Selenium
  # @!visibility private
  class EntireElementScreenshot < Applitools::Selenium::EyesScreenshot
    def sub_screenshot(*_args)
      self
    end

    def screenshot_offset
      region_provider.eye_region.location
    end

    def top_left_location
      @top_left_location ||= screenshot_offset
    end
  end
end
