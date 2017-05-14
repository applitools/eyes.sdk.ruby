module Applitools
  class AppEnvironment
    attr_accessor :os, :hosting_app, :display_size, :inferred_environment

    def initialize(options = {})
      @os = options[:os]
      @hosting_app = options[:hosting_app]
      @display_size = options[:display_size]
      @inferred = options[:inferred]
    end

    def to_hash
      {
        'os' => @os,
        'hostingApp' => @hosting_app,
        'displaySize' => @display_size.to_hash,
        'inferred' => @inferred
      }
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
