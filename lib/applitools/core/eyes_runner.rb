# frozen_string_literal: true

module Applitools
  class EyesRunner
    attr_accessor :batches_server_connectors_map
    attr_accessor :universal_client, :universal_eyes_manager

    def initialize
      self.batches_server_connectors_map = {}
      self.universal_client = Applitools::Connectivity::UniversalClient.new
      self.universal_eyes_manager = nil # eyes.open
    end

    def add_batch(batch_id, &block)
      batches_server_connectors_map[batch_id] ||= block if block_given?
    end

    def delete_all_batches
      batches_server_connectors_map.each_value { |v| v.call if v.respond_to? :call }
    end

    def get_universal_eyes_manager
      return universal_eyes_manager if universal_eyes_manager
      self.universal_eyes_manager = universal_client.make_manager(universal_eyes_manager_config.to_hash)
    end

    def close_all_eyes
      get_universal_eyes_manager.close_all_eyes
    end
  end
end
