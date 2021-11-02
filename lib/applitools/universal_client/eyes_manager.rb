require 'applitools/universal_client/eyes'

module Applitools
  module UniversalClient
    class EyesManager

      extend Forwardable
      def_delegators Applitools::EyesLogger, :logger

      def initialize(manager, universal_client)
        @manager = manager
        @universal_client = universal_client
      end

      def open_eyes(driver, config)
        driver_config_json = driver_config(driver)
        # Applitools::EyesLogger.logger.debug "Driver: #{driver_config_json}"
        # Applitools::EyesLogger.logger.debug "open config: #{config}"

        @eyes = @universal_client.eyes_manager_make_eyes(@manager, driver_config_json, config)

        if @eyes[:message] && @eyes[:stack]
          Applitools::EyesLogger.logger.debug "Eyes not opened: #{@eyes[:message]}"
          Applitools::EyesLogger.logger.debug "Stack for #{Applitools::UniversalClient::UniversalClient::EYES_MANAGER_MAKE_EYES} : #{@eyes[:stack]}"
          return nil
        end

        Applitools::EyesLogger.logger.debug "Eyes applitools-ref-id: #{@eyes[:"applitools-ref-id"]}"
        Eyes.new(@eyes, @universal_client)
      end

      def close_all_eyes
        @universal_client.eyes_manager_close_all_eyes(@manager)
      end

      # private

      def server_url(driver)
        driver.instance_variable_get(:@bridge).http.instance_variable_get(:@server_url).to_s
      end

      def session_id(driver)
        driver.session_id
      end

      def capabilities(driver)
        driver.capabilities.as_json
      end

      def driver_config(driver)
        _driver = driver.is_a?(::Appium::Driver) ? driver.driver : driver
        {
          serverUrl: server_url(_driver),
          sessionId: session_id(_driver),
          capabilities: capabilities(_driver)
        }
      end

    end
  end
end
