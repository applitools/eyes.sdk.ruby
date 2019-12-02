# frozen_string_literal: true

require_relative 'eyes_runner'
module Applitools
  class ClassicRunner < EyesRunner
    attr_accessor :all_test_results, :all_pending_exceptions
    def initialize
      super
      self.all_test_results = []
      self.all_pending_exceptions = {}
    end

    def aggregate_result(test_result)
      Applitools::ArgumentGuard.is_a?(test_result, 'test_result', Applitools::TestResults)
      all_test_results << test_result
    end

    def aggregate_exceptions(result, exception)
      all_pending_exceptions[result] = exception
    end

    def get_all_test_results(throw_exception = false)
      begin
        if throw_exception
          all_pending_exceptions.each do |_result, exception|
            raise exception
          end
        end
      ensure
        delete_all_batches
      end
      all_test_results
    end
  end
end
