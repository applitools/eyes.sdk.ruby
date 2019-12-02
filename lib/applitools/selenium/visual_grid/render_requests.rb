# frozen_string_literal: true
module Applitools
  module Selenium
    class RenderRequests < Array
      include Applitools::Jsonable

      def json_data
        json_value(self)
      end
    end
  end
end
