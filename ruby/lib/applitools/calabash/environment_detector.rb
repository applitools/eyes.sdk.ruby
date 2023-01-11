# frozen_string_literal: true

module Applitools
  module Calabash
    module EnvironmentDetector
      extend self

      def android?
        return true if defined?(::Calabash::Android) == 'constant'
        false
      end

      def ios?
        return true if defined?(::Calabash::Cucumber) == 'constant'
        false
      end

      def current_environment
        return :android if android?
        return :ios if ios?
        raise Applitools::EyesError, 'No calabash environment found!'
      end
    end
  end
end
