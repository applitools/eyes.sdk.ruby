# frozen_string_literal: true

require 'applitools/configuration'
require 'applitools/universal_client/refer'
require 'applitools/selenium/concerns/selenium_eyes'
require 'applitools/eyes_logger'

module Applitools
  class EyesBase
    include Applitools::Configuration
    include Applitools::Selenium::Concerns::SeleniumEyes # all checks here
    extend Forwardable

    USE_DEFAULT_TIMEOUT = -1

    def_delegators Applitools::EyesLogger, :logger, :log_handler, :log_handler=
    # def_delegators 'server_connector', :api_key, :api_key=, :server_url, :server_url=, :set_proxy, :proxy, :proxy=
    # def_delegators 'config', *Applitools::EyesBaseConfiguration.methods_to_delegate
    # def_delegators 'config', *Applitools::Selenium::Configuration.methods_to_delegate

    attr_accessor :runner
    attr_reader :driver

    def initialize(*args) # server_url, runner: runner
      @universal_client = Applitools::UniversalClient::UniversalClient.new
      @eyes_manager = nil # eyes.open
      @eyes = nil # eyes.open
      @refer ||= Applitools::UniversalClient::Refer.new
      @driver = nil
      setup_logger
      # NOTE : :agentId by server ?
      # ensure_config
      # self.disabled = false
    end

    def api_key
      configuration.apiKey # api_key = ENV['APPLITOOLS_API_KEY'] # Note : check all variants ...
    end

    # def ensure_config
    #   self.config = Applitools::EyesBaseConfiguration.new
    #   self.config = Applitools::Selenium::Configuration.new
    # end


    def abort
      if disabled?
        Applitools::EyesLogger.logger.info "#{__method__} Ignore disabled"
        return false
      end
      # raise Applitools::EyesNotOpenException.new('Eyes not open!') if @eyes.nil?
      return if @eyes.nil?
      result = @eyes.abort

      if result.is_a? Hash
        Applitools::EyesLogger.logger.info "---Test aborted" if !result[:message] && !result[:stack]
      else
        # TestCheckFrameInFrame_Fully_Fluent_VG\
        # require('pry')
        # binding.pry
      end
    end


    def open(driver, config = nil)
      # return _driver = normalize_driver(driver)
      @driver = normalize_driver(driver)
      if disabled?
        Applitools::EyesLogger.logger.info "#{__method__} Ignore disabled"
        return @driver
      end
      make_eyes_manager
      Applitools::EyesLogger.logger.info "Applitools::Selenium::Eyes opening ..."
      open_config = normalize_open_config(config) # update_config_from_options(options)
      # { session_type: 'SEQUENTIAL' }.merge options # app_name, test_name, viewport_size, session_type
      # raise Applitools::EyesIllegalArgument, config.validation_errors.values.join('/n') unless config.valid?
      # raise Applitools::EyesError.new 'API key is missing! Please set it using api_key=' if api_key.nil? || (api_key && api_key.empty?)

      # require('pry')
      # binding.pry

      @eyes = @eyes_manager.open_eyes(@driver, open_config)
      raise Applitools::EyesNotOpenException.new('Eyes not open!') if @eyes.nil?
      Applitools::EyesLogger.logger.info "Done!"
      @driver
    end


    # Closes eyes
    # @param [Boolean] throw_exception If set to +true+ eyes will trow [Applitools::TestFailedError] exception,
    # otherwise the test will pass. Default is true
    def close(throw_exception = true, be_silent = false)
      if disabled?
        Applitools::EyesLogger.logger.info "#{__method__} Ignore disabled"
        return
      end
      Applitools::EyesLogger.logger.info "close(#{throw_exception})"
      raise Applitools::EyesNotOpenException.new('Eyes not open!') if @eyes.nil?

      results = close_and_get_test_results

      if results.all?(&:passed?)
        results.each {|result| results_passed(result, throw_exception)}
      elsif results.all?(&:is_empty?)
        results.each {|result| results_empty(result, throw_exception)}
      elsif results.any?(&:failed?)
        results.each {|result| results_failed(result, throw_exception)}
      elsif results.any? {|result| result.unresolved? && result.new? }
        results.each {|result| results_new(result, throw_exception)} # logger.info "Automatically save test? #{save}"
      elsif results.any? {|result| result.unresolved? && !result.new? }
        results.each {|result| results_unresolved(result, throw_exception)}
      else
        results.each {|result| results_wtf(result, throw_exception)}
      end
      results.first
    end

    # def disabled=(value)
    #   @disabled = Applitools::Utils.boolean_value value
    # end

    def disabled?
      # @disabled
      configuration.isDisabled
    end

    private


    def setup_logger
      Applitools::EyesLogger.log_handler = Logger.new(STDOUT) unless ENV['TRAVIS'] # ...
    end

    def normalize_driver(driver)
      driver.is_a?(Hash) && !!driver[:driver] ? driver[:driver] : driver
    end

    def normalize_open_config(config)
      return config if config
      configuration.hideScrollbars = true if configuration.vg && configuration.hideScrollbars.nil?
      configuration.to_socket_output
    end

    def make_eyes_manager
      Applitools::EyesLogger.logger.info "#{configuration.testName} : Starting EyesManager ..."
      eyes_manager_config = normalize_eyes_manager_config
      @eyes_manager = @universal_client.make_manager(eyes_manager_config)
      Applitools::EyesLogger.logger.info "Done!"
    end

    def normalize_eyes_manager_config
      if configuration.vg
        { type: 'vg', concurrency: 1, legacy: false }
      else
        { type: 'classic' }
      end
    end

    def close_and_get_test_results
      Applitools::EyesLogger.logger.info 'Ending server session...'
      results = @eyes.close
      if results.is_a?(Array)
        key_transformed_results = Applitools::Utils.deep_stringify_keys(results)
        key_transformed_results.map {|result| Applitools::TestResults.new(result) }
      else
        [Applitools::TestResults.new(results)]
      end
    end

    def results_log_message_parts(results)
      session_results_url = results.batch_results_url
      scenario_id_or_name = results.name
      app_id_or_name = results.app_id_or_name
      # for server errors :
      scenario_id_or_name = configuration.testName if scenario_id_or_name.nil? || scenario_id_or_name.empty?
      app_id_or_name = configuration.appName if app_id_or_name.nil? || app_id_or_name.empty?
      [session_results_url, scenario_id_or_name, app_id_or_name]
    end

    def results_passed(results, throw_exception)
      Applitools::EyesLogger.logger.info '--- Test passed'
    end

    def results_empty(results, throw_exception)
      Applitools::EyesLogger.logger.info '--- Empty test ended.'
    end

    def results_failed(results, throw_exception)
      session_results_url, scenario_id_or_name, app_id_or_name = results_log_message_parts(results)
      Applitools::EyesLogger.logger.info "--- Failed test ended. see details at #{session_results_url}"
      error_message = "Test '#{scenario_id_or_name}' of '#{app_id_or_name}' " \
            "is failed! See details at #{session_results_url}"
      raise Applitools::TestFailedError.new error_message, results if throw_exception
    end

    def results_new(results, throw_exception)
      session_results_url, scenario_id_or_name, app_id_or_name = results_log_message_parts(results)
      Applitools::EyesLogger.logger.info "--- New test ended. see details at #{session_results_url}"
      error_message = "New test '#{scenario_id_or_name}' " \
            "of '#{app_id_or_name}' " \
            "Please approve the baseline at #{session_results_url} "
      raise Applitools::NewTestError.new error_message, results if throw_exception
    end

    def results_unresolved(results, throw_exception)
      session_results_url, scenario_id_or_name, app_id_or_name = results_log_message_parts(results)
      Applitools::EyesLogger.logger.info "--- Differences are found. see details at #{session_results_url}"
      error_message = "Test '#{scenario_id_or_name}' " \
            "of '#{app_id_or_name}' " \
            "detected differences! See details at #{session_results_url}"
      raise Applitools::DiffsFoundError.new error_message, results if throw_exception
    end

    def results_wtf(results, throw_exception)
      _, scenario_id_or_name, app_id_or_name = results_log_message_parts(results)
      original_result_message = 'Unknown'
      # original_result_message = results.original_results['message'] if results.original_results && results.original_results['message']
      original_result_message = results.original_results[:message] if results.original_results && results.original_results[:message]
      error_message = "Test '#{scenario_id_or_name}' of '#{app_id_or_name}' " \
            "is failed! Details: #{original_result_message}"
      Applitools::EyesLogger.logger.info "--- >>> Please Check Results of this Test (#{scenario_id_or_name} of #{app_id_or_name})<<< ---"
      raise Applitools::TestFailedError.new error_message, results if throw_exception
    end

  end
end
