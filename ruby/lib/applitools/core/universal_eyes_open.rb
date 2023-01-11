# frozen_string_literal: true

module Applitools
  module UniversalEyesOpen

    # Starts a test
    #
    # @param options [Hash] options
    # @option options :driver The driver that controls the browser hosting the application
    #   under the test. (*Required* option)
    # @option options [String] :app_name The name of the application under the test. (*Required* option)
    # @option options [String] :test_name The test name (*Required* option)
    # @option options [String | Hash] :viewport_size The required browser's viewport size
    #   (i.e., the visible part of the document's body) or +nil+ to use the current window's viewport.
    # @option options :session_type The type of the test (e.g., standard test / visual performance test).
    #   Default value is 'SEQUENTAL'
    # @return [Applitools::Selenium::Driver] A wrapped web driver which enables Eyes
    #   trigger recording and frame handling
    def universal_open(options = {})
      original_driver = options.delete(:driver)
      if self.class.name != 'Applitools::Images::Eyes'
        Applitools::ArgumentGuard.not_nil original_driver, 'options[:driver]'

        if respond_to?(:disabled?) && disabled?
          logger.info('Ignored')
          return original_driver
        end

        self.driver = Applitools::Selenium::SeleniumEyes.eyes_driver(original_driver, self)
      end

      update_config_from_options(options)
      universal_driver_config = driver.universal_driver_config if self.class.name != 'Applitools::Images::Eyes'
      universal_eyes_manager = runner.get_universal_eyes_manager

      universal_eyes_config = Applitools::UniversalEyesConfig.new
      universal_eyes_config.from_original_sdk(self)

      # require('pry')
      # binding.pry

      @universal_eyes = universal_eyes_manager.open_eyes(universal_driver_config, universal_eyes_config.to_hash)
      raise Applitools::EyesNotOpenException.new('Eyes not open!') if @universal_eyes.nil?

      self.open = true if respond_to?(:open=, true)
      self.running_session = true if respond_to?(:running_session=, true)
      if self.class.name != 'Applitools::Images::Eyes'
        driver
      else
        self.open?
      end
    rescue Applitools::EyesError => e
      logger.error e.message
      raise e
    end

    def universal_sdk_abort
      if respond_to?(:disabled?) && disabled?
        logger.info "#{__method__} Ignore disabled"
        return false
      end
      # raise Applitools::EyesNotOpenException.new('Eyes not open!') if @eyes.nil?
      return if @universal_eyes.nil?
      result = @universal_eyes.abort

      if result.is_a? Hash
        logger.info "---Test aborted" if !result[:message] && !result[:stack]
      else
        # TestCheckFrameInFrame_Fully_Fluent_VG\
        # require('pry')
        # binding.pry
      end
    end

    private

    def update_config_from_options(options)
      default_options = { session_type: 'SEQUENTIAL' }

      options = default_options.merge options

      self.app_name = options[:app_name] if options[:app_name]
      self.test_name = options[:test_name] if options[:test_name]
      if (config.viewport_size.nil? || config.viewport_size&.empty?) && options[:viewport_size]
        self.viewport_size = Applitools::RectangleSize.from_any_argument options[:viewport_size]
      end
      self.session_type = options[:session_type] if options[:session_type]

      raise Applitools::EyesIllegalArgument, config.validation_errors.values.join('/n') unless config.valid?

      logger.info "Agent = #{full_agent_id}"
      logger.info "open(app_name: #{app_name}, test_name: #{test_name}," \
          " viewport_size: #{viewport_size})"

      raise Applitools::EyesError.new 'API key is missing! Please set it using api_key=' if
        api_key.nil? || (api_key && api_key.empty?)

      logger.info "Batch is #{@batch}" if @batch
      app_env = app_environment if respond_to? :app_environment
      logger.info "Application environment is #{app_env}"
      test_info = "'#{test_name}' of '#{app_name}' #{app_env}"
      logger.info "--- New test started - #{test_info}"
    end

  end
end
