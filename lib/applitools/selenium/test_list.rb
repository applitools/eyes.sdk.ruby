# frozen_string_literal: true

module Applitools
  module Selenium
    class TestList < Array
      def <<(value)
        unless value.is_a? Applitools::Selenium::RunningTest
          raise(
            Applitools::EyesIllegalArgument,
            "Expected value to be instance of Applitools::Selenium::RunningTest but got #{value.class} instead"
          )
        end
        super
      end

      def push(*args)
        wrong_values = args.select { |a| !a.is_a? Applitools::Selenium::RunningTest }
        unless wrong_values.empty?
          raise(
            Applitools::EyesIllegalArgument,
            'Expected values to contain only Applitools::Selenium::RunningTest instances, ' \
            "but got [#{wrong_values.map(&:class).join(', ')}]"
          )
        end
        super
      end
    end
  end
end
