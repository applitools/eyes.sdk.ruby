# frozen_string_literal: true

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
        match_window_data.convert_floating_regions_coordinates
        match_window_data.convert_layout_regions_coordinates
        match_window_data.convert_strict_regions_coordinates
        match_window_data.convert_content_regions_coordinates
        match_window_data.convert_accessibility_regions_coordinates
        match_window_data.replace_last = false
        match_result = perform_match(match_window_data)
      else
        app_output = app_output_provider.app_output(region_provider, last_screenshot)
        last_image_digest = app_output.screenshot.image.sha256
        match_window_data.app_output = app_output
        match_window_data.convert_ignored_regions_coordinates
        match_window_data.convert_floating_regions_coordinates
        match_window_data.convert_layout_regions_coordinates
        match_window_data.convert_strict_regions_coordinates
        match_window_data.convert_content_regions_coordinates
        match_window_data.convert_accessibility_regions_coordinates
        match_window_data.replace_last = false
        match_result = perform_match(match_window_data)

        block_retry = if block_given?
                        yield(match_result)
                      else
                        false
                      end
        start = Time.now
        retry_time = 0

        while retry_time < retry_timeout && !(block_retry || match_result.as_expected?)
          sleep MATCH_INTERVAL
          app_output = app_output_provider.app_output(region_provider, last_screenshot)
          image_digest = app_output.screenshot.image.sha256
          if image_digest == last_image_digest
            logger.info('Got the same screenshot in retry. Not sending to the server.')
          else
            match_window_data.app_output = app_output
            match_window_data.convert_ignored_regions_coordinates
            match_window_data.convert_floating_regions_coordinates
            match_window_data.convert_layout_regions_coordinates
            match_window_data.convert_strict_regions_coordinates
            match_window_data.convert_content_regions_coordinates
            match_window_data.convert_accessibility_regions_coordinates
            match_window_data.replace_last = true
            match_result = perform_match(match_window_data)
          end
          last_image_digest = image_digest
          retry_time = Time.now - start
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
