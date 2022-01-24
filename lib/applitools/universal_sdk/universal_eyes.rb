# frozen_string_literal: true

module Applitools
  class UniversalEyes

    extend Forwardable
    def_delegators 'Applitools::EyesLogger', :logger

    def initialize(eyes, universal_client)
      @eyes = eyes
      @universal_client = universal_client
    end

    def check(settings)
      elapsed_time_start = Time.now
      # Applitools::EyesLogger.logger.debug "check settings: #{settings}"
      check_result = @universal_client.eyes_check(@eyes, settings)
      # Applitools::EyesLogger.logger.debug "check_result: #{check_result}"
      Applitools::EyesLogger.logger.info "Completed in #{format('%.2f', Time.now - elapsed_time_start)} seconds"
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
# U-Notes : Added internal Applitools::UniversalEyes