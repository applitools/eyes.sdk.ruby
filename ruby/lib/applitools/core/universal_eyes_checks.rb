# frozen_string_literal: true

module Applitools
  module UniversalEyesChecks

    # Takes a snapshot and matches it with the expected output.
    #
    # @param [String] name The name of the tag.
    # @param [Applitools::Selenium::Target] target which area of the window to check.
    # @return [Applitools::MatchResult] The match results.
    def universal_check(name, target)
      return disabled_result if respond_to?(:disabled?) && disabled?

      raise Applitools::EyesNotOpenException.new('Eyes not open!') if @universal_eyes.nil?
      Applitools::EyesLogger.logger.info "#{test_name} : check(#{name}) started  ..."
      settings = get_universal_check_settings(name, target)
      image_target = settings[:image].nil? ? {} : { image: settings.delete(:image) }
      # require 'pry'
      # binding.pry
      check_result = @universal_eyes.check(settings, image_target)
      if server_error?(check_result)
        # require 'pry'
        # binding.pry
        raise Applitools::EyesError.new("Request failed: #{check_result[:message]}")
      end

      if check_result != {}
        result = Applitools::MatchResult.new(Applitools::Utils.deep_stringify_keys(check_result[0]))

        check_fail_result_processing(name) unless result.as_expected?
      end

      logger.info 'Done!'
      result
    end

    private

    def disabled_result
      logger.info "#{__method__} Ignored"
      result = Applitools::MatchResults.new
      result.as_expected = true
      result
    end

    def get_universal_check_settings(name, target)
      universal_check_settings = Applitools::UniversalCheckSettings.new(name: name)
      universal_check_settings.from_original_target(target, self)
      # require 'pry'
      # binding.pry
      universal_check_settings.to_hash
    end

    def check_fail_result_processing(name)
      self.failed = true
      logger.info "Mistmatch! #{name}" #unless running_session.new_session?

      if failure_reports == :immediate
        raise Applitools::TestFailedException.new "Mistmatch found in #{test_name} of #{app_name}"
      end
    end

    def server_error?(universal_results)
      universal_results.is_a?(Hash) && universal_results[:message] && universal_results[:stack]
    end

  end
end
# U-Notes : Added internal Applitools::UniversalEyesChecks
