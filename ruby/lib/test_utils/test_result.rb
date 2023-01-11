module Applitools
  module TestUtils
    class TestResult
      include Applitools::Jsonable
      json_fields :test_name, :parameters, :passed

      class Parameters
        include Applitools::Jsonable
        json_fields :browser, :stitching, :mode
        def initialize(options = {})
          self.browser = options[:browser]
          self.stitching = options[:stitching]
          self.mode = options[:mode]
        end
      end

      def initialize(options = {})
        params = Parameters.new(browser: options[:browser], stitching: options[:stitching], mode: options[:mode])
        self.parameters = params
        self.test_name = options[:test_name]
        self.passed = options[:passed] ? true : false
      end
    end
  end
end