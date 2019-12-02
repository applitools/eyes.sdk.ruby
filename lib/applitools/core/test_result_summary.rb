# frozen_string_literal: true

module Applitools
  class TestResultSummary
    attr_accessor :results, :passed, :unresolved, :failed, :exceptions, :mismatches, :missing, :matches
    def initialize(results)
      Applitools::ArgumentGuard.is_a?(results, 'results', Array)
      results.each_with_index do |r, i|
        Applitools::ArgumentGuard.is_a?(r, "results[#{i}]", Applitools::TestResults)
      end
    end
  end
end
