# frozen_string_literal: true

require 'securerandom'
require_relative 'helpers'

module Applitools
  class BatchInfo
    extend Helpers
    attr_accessor :started_at, :id

    environment_attribute :name, 'APPLITOOLS_BATCH_NAME'
    environment_attribute :id, 'APPLITOOLS_BATCH_ID'

    def initialize(name = nil, started_at = Time.now)
      self.name = name if name
      @started_at = started_at
      self.id = SecureRandom.uuid unless id
    end

    def to_hash
      {
        'id' => id,
        'name' => name,
        'startedAt' => @started_at.iso8601
      }
    end

    def to_s
      to_hash.to_s
    end
  end
end
