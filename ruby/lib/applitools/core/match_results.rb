# frozen_string_literal: true

module Applitools
  class MatchResults
    attr_accessor :screenshot, :window_id, :as_expected

    def as_expected?
      as_expected
    end
  end
end
