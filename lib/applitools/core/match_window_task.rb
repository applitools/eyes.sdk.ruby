require 'base64'
module Applitools
  class MatchWindowTask
    MATCH_INTERVAL = 0.5
    AppOuptut = Struct.new(:title, :screenshot64)

    attr_reader :logger, :running_session, :default_retry_timeout, :app_output_provider

    def initialize(logger, running_session, retry_timeout, app_output_provider, server_connector)
      Applitools::ArgumentGuard.is_a? server_connector, 'server_connector', Applitools::Connectivity::ServerConnector
      @logger = logger
      @running_session = running_session
      # @driver = driver
      @default_retry_timeout = retry_timeout
      @app_output_provider = app_output_provider
      self.server_connector = server_connector

      ArgumentGuard.not_nil logger, 'logger'
      ArgumentGuard.not_nil running_session, 'running_session'
      ArgumentGuard.not_nil app_output_provider, 'app_output_provider'
      ArgumentGuard.greater_than_or_equal_to_zero retry_timeout, 'retry_timeout'

      return if app_output_provider.respond_to? :app_output
      raise Applitools::EyesIllegalArgument.new 'MatchWindowTask.new(): app_output_provider doesn\'t' /
        ' respond to :app_output'
    end

    def match_window(match_window_data, options = {})
      last_screenshot = options[:last_screenshot]
      region_provider = options[:region_provider]
      retry_timeout = options[:retry_timeout]
      should_match_window_run_once_on_timeout = options[:should_match_window_run_once_on_timeout]

      retry_timeout = default_retry_timeout if retry_timeout < 0

      logger.info "retry_timeout = #{retry_timeout}"
      elapsed_time_start = Time.now

      if retry_timeout.zero? || should_match_window_run_once_on_timeout
        sleep retry_timeout if should_match_window_run_once_on_timeout
        app_output = app_output_provider.app_output(region_provider, last_screenshot)
        match_window_data.app_output = app_output
        match_window_data.convert_ignored_regions_coordinates
        match_result = perform_match(match_window_data)
      else
        passed_ignore_mismatch = match_window_data.ignore_mismatch
        app_output = app_output_provider.app_output(region_provider, last_screenshot)
        match_window_data.app_output = app_output
        match_window_data.convert_ignored_regions_coordinates
        match_window_data.ignore_mismatch = true
        start = Time.now
        match_result = perform_match(match_window_data)
        retry_time = Time.now - start

        block_retry = if block_given?
                        yield(match_result)
                      else
                        false
                      end

        while retry_time < retry_timeout && !(block_retry || match_result.as_expected?)
          sleep MATCH_INTERVAL
          app_output = app_output_provider.app_output(region_provider, last_screenshot)
          match_window_data.app_output = app_output
          match_window_data.convert_ignored_regions_coordinates
          match_window_data.ignore_mismatch = true
          match_result = perform_match(match_window_data)
          retry_time = Time.now - start
        end

        unless block_retry || match_result.as_expected?
          app_output = app_output_provider.app_output(region_provider, last_screenshot)
          match_window_data.app_output = app_output
          match_window_data.convert_ignored_regions_coordinates
          match_window_data.ignore_mismatch = passed_ignore_mismatch
          match_result = perform_match(match_window_data)
        end
      end

      logger.info "Completed in #{format('%.2f', Time.now - elapsed_time_start)} seconds"

      match_result.screenshot = app_output.screenshot
      match_result
    end

    private

    attr_accessor :server_connector

    def perform_match(match_window_data)
      Applitools::ArgumentGuard.is_a? match_window_data, 'match_window_data', Applitools::MatchWindowData
      server_connector.match_window running_session, match_window_data
    end
  end
end
