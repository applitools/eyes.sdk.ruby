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
      if self.class.respond_to? :default_config
        default_config = self.class.default_config
        default_config.keys.each do |k|
          unless default_config[k].nil?
            send "#{k}=", default_config[k].deep_clone if default_config[k].respond_to?(:deep_clone)
            send "#{k}=", default_config[k].clone if default_config[k].respond_to?(:clone)
            send "#{k}=", default_config[k].clone unless default_config[k].respond_to?(:clone) || default_config[k].respond_to?(:deep_clone)
          end
        end
      end
    end

    def deep_clone
      new_config = self.class.new
      config_keys.each do |k|
        new_config.send(
          "#{k}=", case value = send(k)
                   when Symbol, FalseClass, TrueClass, Integer, Float, NilClass
                     value
                   else
                     value.clone
                   end
        )
      end
      new_config
    end

    alias deep_dup deep_clone
  end
end
