# frozen_string_literal: true

module Applitools
  class EyesRunner
    attr_accessor :batches_server_connectors_map

    def initialize
      self.batches_server_connectors_map = {}
    end

    def add_batch(batch_id, &block)
      batches_server_connectors_map[batch_id] ||= block if block_given?
    end

    def delete_all_batches
      batches_server_connectors_map.each_value { |v| v.call if v.respond_to? :call }
    end
  end
end
