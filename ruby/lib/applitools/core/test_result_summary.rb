# frozen_string_literal: true

module Applitools
  class TestResultSummary
    attr_accessor :results, :passed, :unresolved, :failed, :exceptions, :mismatches, :missing, :matches
    attr_accessor :original_test_results
    def initialize(all_test_results)
      @original_test_results = all_test_results
      @results = all_test_results[:results]
      @passed = all_test_results[:passed]
      @unresolved = all_test_results[:unresolved]
      @failed = all_test_results[:failed]
      @exceptions = all_test_results[:exceptions]
      @mismatches = all_test_results[:mismatches]
      @missing = all_test_results[:missing]
      @matches = all_test_results[:matches]
    end

    def old_style_results_array
      Applitools::Utils.deep_stringify_keys(results).map do |e|
        r = e['result'] ? e['result'] : {}
        Applitools::TestResults.new(r)
      end
    end
  end
end
