module Applitools
  module UniversalClient
    class Eyes

      extend Forwardable
      def_delegators Applitools::EyesLogger, :logger

      def initialize(eyes, universal_client)
        @eyes = eyes
        @universal_client = universal_client
      end

      def check(settings)
        Applitools::EyesLogger.logger.debug "check settings: #{settings}"
        check_result = @universal_client.eyes_check(@eyes, settings)
        Applitools::EyesLogger.logger.debug "check_result: #{check_result}"
        check_result
      end

      def close
        @universal_client.eyes_close(@eyes)
      end

      def abort
        @universal_client.eyes_abort(@eyes)
      end

      def locate(settings)
        @universal_client.eyes_locate(@eyes, settings)
      end

      def extract_text_regions(patterns_array)
        @universal_client.eyes_extract_text_regions(@eyes, patterns_array)
      end

      def extract_text(targets_array)
        @universal_client.eyes_extract_text(@eyes, targets_array)
      end

    end
  end
end
