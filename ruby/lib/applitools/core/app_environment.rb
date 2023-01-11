# frozen_string_literal: false

module Applitools
  class AppEnvironment
    attr_accessor :os, :hosting_app, :display_size, :inferred_environment, :device_info

    def initialize(options = {})
      self.os = options[:os]
      self.hosting_app = options[:hosting_app]
      self.display_size = options[:display_size]
      self.inferred_environment = options[:inferred]
      self.device_info = options[:device_info]
    end

    def json_data
      {
          'os' => os,
          'hostingApp' => hosting_app,
          'displaySize' => display_size && display_size.to_hash,
          'inferred' => inferred_environment,
          'deviceInfo' => device_info.nil? || device_info.empty? ? 'Desktop' : device_info
      }
    end

    def to_hash
      json_data
    end

    def to_s
      result = ''
      to_hash.each_pair do |k, v|
        result << "#{k}: #{v}; "
      end
      result
    end
  end
end
