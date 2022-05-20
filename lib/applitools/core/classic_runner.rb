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
      # return all_test_results unless all_test_results.empty?
      all_universal_results = close_all_eyes
      test_result_summary = Applitools::TestResultSummary.new(all_universal_results).old_style_results_array
      return [] if test_result_summary.reject { |tr| tr.aborted? }.empty?
      test_result_summary
    end

    def rendering_info(connector)
      @rendering_info ||= RenderingInfo.new(connector.rendering_info)
    end

    def universal_eyes_manager_config
      Applitools::UniversalEyesManagerConfig.classic
    end
  end
end
