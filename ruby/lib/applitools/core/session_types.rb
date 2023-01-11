# frozen_string_literal: true

module Applitools
  module SessionTypes
    extend self
    SEQUENTIAL = 'SEQUENTIAL'
    PROGRESSION = 'PROGRESSION'

    def enum_values
      [SEQUENTIAL, PROGRESSION]
    end
  end
end
