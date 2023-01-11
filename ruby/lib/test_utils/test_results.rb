module Applitools
  module TestUtils
    class TestResults
      include Applitools::Jsonable
      json_fields :sdk, :group, :id, :sandbox, :mandatory, :results

      def initialize(options = {})
        self.sdk = options[:sdk]
        self.group = options[:group]
        self.id = options[:id]
        self.sandbox = options[:sandbox] ? true : false
        self.mandatory = options[:mandatory] ? true : false
        self.results = []
      end
    end
  end
end