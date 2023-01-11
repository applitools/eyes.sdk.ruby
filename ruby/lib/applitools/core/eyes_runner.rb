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

    # def close_batch(batch_id)
    #   if 'true'.casecmp(ENV['APPLITOOLS_DONT_CLOSE_BATCHES'] || '') == 0
    #     return Applitools::EyesLogger.info(
    #       'APPLITOOLS_DONT_CLOSE_BATCHES environment variable set to true. Doing nothing.'
    #     ) && false
    #   end
    #   Applitools::ArgumentGuard.not_nil(batch_id, 'batch_id')
    #   Applitools::EyesLogger.info("Close batch called with #{batch_id}")
    #
    #   close_batches_result = universal_client.core_close_batches(batch_id)
    #   if close_batches_result.is_a?(Hash) && close_batches_result[:message] && close_batches_result[:stack]
    #     Applitools::EyesLogger.logger.debug "Eyes close Batch: #{close_batches_result[:message]}"
    #     Applitools::EyesLogger.logger.debug "Stack for #{Applitools::Connectivity::UniversalClient::CORE_CLOSE_BATCHES} : #{close_batches_result[:stack]}"
    #   else
    #     Applitools::EyesLogger.info "delete batch is done with #{close_batches_result}"
    #   end
    # end
  end
end
