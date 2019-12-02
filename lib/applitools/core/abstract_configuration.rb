# frozen_string_literal: true

require 'applitools/core/eyes_configuration_dsl'

module Applitools
  class AbstractConfiguration
    attr_reader :config_hash
    attr_accessor :validation_errors
    extend Applitools::EyesConfigurationDSL

    def initialize
      @config_hash = {}
      self.validation_errors = {}
      default_config = self.class.default_config
      default_config.keys.each do |k|
        send "#{k}=", default_config[k]
      end
    end
  end
end
