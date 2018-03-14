# frozen_string_literal: true

module Applitools
  class AppOutput
    attr_reader :title, :screenshot64

    def initialize(title, screenshot64)
      @title = title
      @screenshot64 = screenshot64
    end

    def to_hash
      {
        title: title,
        screenshot64: nil
      }
    end
  end
end
