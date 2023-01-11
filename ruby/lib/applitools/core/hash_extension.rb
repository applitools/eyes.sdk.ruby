# frozen_string_literal: true

module Applitools::HashExtension
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
    def struct_define_to_h_method
      define_singleton_method :to_h do
        result = {}
        each_pair { |k, v| result[k] = v }
        result
      end
    end
  end
end
