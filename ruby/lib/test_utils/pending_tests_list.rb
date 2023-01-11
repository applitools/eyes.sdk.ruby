module Applitools
  module TestUtils
    module PendingTestsList
      extend self
      def load_pending_list_from_yaml
        YAML.load_file(filename)
      end

      def test_list
        result = []
        yaml = load_pending_list_from_yaml
        yaml.keys.each do |k|
          result << yaml[k] if yaml[k].is_a?(Array)
        end
        result.compact.flatten
      end

      def filename
        'pending_tests.yml'
      end
    end
  end
end