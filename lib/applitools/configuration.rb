# frozen_string_literal: true

require 'applitools/utils/Configuration'
require 'ostruct'

CLI_CONFIGURATION = true

module Applitools
  module Configuration
    extend self
    attr_accessor :config_cl

    def configuration
      unless CLI_CONFIGURATION
        @config ||= OpenStruct.new
        @config = @config.to_h.empty? ? @config : OpenStruct.new(transform_config_keys(@config.to_h))
        @config
      else
        @config_cl
      end
    end

    def configure
      unless CLI_CONFIGURATION
        yield(configuration)
      else
        @config_cl ||= Applitools::Utils::Configuration.new
        yield(@config_cl)
      end
    end

    private

    def transform_config_keys(config)
      config.map do |k,v|
        v = v.to_socket_output if v.respond_to?(:to_socket_output)
        if k.to_s.include?('_')
          key = k.to_s.split('_').map(&:capitalize).join
          key[0] = key[0].downcase
          [key.to_sym, v]
        else
          [k, v]
        end
      end.to_h
    end
  end # Configuration
end # Applitools

