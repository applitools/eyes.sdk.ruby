# frozen_string_literal: true

module Applitools
  class Trigger
    TRIGGER_TYPE = :unknown
    def trigger_type
      self.class::TRIGGER_TYPE
    end
  end
end
