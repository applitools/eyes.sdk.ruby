# frozen_string_literal: true

require 'securerandom'
require 'applitools/utils/utils'
require_relative 'helpers'

module Applitools
  class BatchInfo
    extend Helpers
    attr_accessor :started_at, :id, :notify_on_completion, :properties

    environment_attribute :name, 'APPLITOOLS_BATCH_NAME'
    environment_attribute :id, 'APPLITOOLS_BATCH_ID'
    environment_attribute :sequence_name, 'APPLITOOLS_BATCH_SEQUENCE'
    environment_attribute :env_notify_on_completion, 'APPLITOOLS_BATCH_NOTIFY'


    def initialize(args = nil, started_at = Time.now)
      case args
        when String
          name = args
        when Hash
          sym_args = Applitools::Utils.symbolize_keys args
          id ||= sym_args[:id]
          name ||= sym_args[:name]
          properties ||= sym_args[:properties]
      end
      self.name = name if name
      @started_at = started_at
      self.id = id || SecureRandom.uuid
      self.properties = properties if properties
      self.notify_on_completion = 'true'.casecmp(env_notify_on_completion || '') == 0 ? true : false
    end

    def json_data
      {
          'id' => id,
          'name' => name,
          'startedAt' => @started_at.iso8601,
          'batchSequenceName' => sequence_name,
          'notifyOnCompletion' => notify_on_completion,
          'properties' => properties
      }
    end

    def to_hash
      json_data
    end

    def to_s
      to_hash.to_s
    end
  end
end
