# frozen_string_literal: true

require 'securerandom'

module Applitools
  class BatchInfo
    attr_accessor :name, :started_at, :id
    def initialize(name = nil, started_at = Time.now)
      @name = name
      @started_at = started_at
      @id = SecureRandom.uuid
    end

    def to_hash
      {
        'id' => @id,
        'name' => @name,
        'startedAt' => @started_at.iso8601
      }
    end

    def to_s
      to_hash.to_s
    end
  end
end
