# frozen_string_literal: true

module Applitools
  module Selenium
    class RenderResources < Hash
      class ResourceMissingInCache < EyesError; end
      def []=(key, value)
        unless key.is_a? URI
          raise Applitools::EyesIllegalArgument, "Expected key to be an instance of URI (but got #{key.class}) - #{key}"
        end
        unless value.is_a? Applitools::Selenium::VGResource
          raise(
            Applitools::EyesIllegalArgument, 'Expected value to be an instance of Applitools::Selenium::VGResource' \
            " (but got #{value.class}) - #{key}:#{value}"
          )
        end
        super
      end
    end
  end
end
