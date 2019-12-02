# frozen_string_literal: true

module Applitools
  module Selenium
    class WebElementRegion
      include Applitools::Jsonable
      json_fields :selector, :category, :type

      def initialize(selector, category)
        self.selector = selector
        self.category = category
        self.type = 'xpath'
      end
    end
  end
end
