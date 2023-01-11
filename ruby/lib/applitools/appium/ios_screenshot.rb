require_relative './screenshot.rb'
module Applitools
  module Appium
    class IosScreenshot < Applitools::Appium::Screenshot
      def convert_location(location, _from, _to)
        location.offset_negative(Applitools::Location.new(0, status_bar_height))
      end
    end
  end
end