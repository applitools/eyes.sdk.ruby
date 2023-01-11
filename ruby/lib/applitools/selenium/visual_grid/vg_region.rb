# frozen_string_literal: true
module Applitools
  module Selenium
    class VGRegion
      attr_accessor :region, :padding_proc
      def initialize(region, padding_proc)
        self.region = region
        self.padding_proc = padding_proc
      end

      def to_s
        region.inspect
      end
    end
  end
end
