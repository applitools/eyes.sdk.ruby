# frozen_string_literal: true

require 'applitools/core/helpers'
require 'applitools/core/eyes_screenshot'
require 'applitools/core/eyes_base_configuration'
require 'applitools/core/match_level'
require 'zlib'

require_relative 'match_level_setter'

module Applitools
  MATCH_LEVEL = {
    none: 'None',
    layout: 'Layout',
    layout2: 'Layout2',
    content: 'Content',
    strict: 'Strict',
    exact: 'Exact'
  }.freeze

  class EyesBase
    include Applitools::MatchLevelSetter
    extend Forwardable
    extend Applitools::Helpers

    DEFAULT_MATCH_TIMEOUT = 2 # seconds
    USE_DEFAULT_TIMEOUT = -1

    SCREENSHOT_AS_IS = Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is].freeze
    CONTEXT_RELATIVE = Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative].freeze

    attr_accessor :config

    def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=
    # def_delegators 'server_connector', :api_key, :api_key=, :server_url, :server_url=,
    #   :set_proxy, :proxy, :proxy=

    # @!attribute [rw] verbose_results
    #   If set to true it will display test results in verbose format, including all fields returned by the server
    #   Default value is false.
    #   @return [boolean] verbose_results flag

    # attr_accessor :agent_id, :session_type, :app_name, :test_name,

    attr_accessor :batch, :full_agent_id,
      :match_timeout, :save_new_tests, :save_failed_tests, :failure_reports, :default_match_settings, :cut_provider,
      :scale_ratio, :position_provider, :viewport_size, :verbose_results,
      :inferred_environment, :remove_session_if_matching, :server_scale, :server_remainder, :exact,
      :compare_with_parent_branch, :results, :runner

    abstract_attr_accessor :base_agent_id
    abstract_method :capture_screenshot, true
    abstract_method :title, true
    abstract_method :set_viewport_size, true
    abstract_method :get_viewport_size, true

    # environment_attribute :branch_name, 'APPLITOOLS_BRANCH'
    # environment_attribute :parent_branch_name, 'APPLITOOLS_PARENT_BRANCH'
    # environment_attribute :baseline_env_name, 'APPLITOOLS_BASELINE_BRANCH'

    def_delegators 'config', *Applitools::EyesBaseConfiguration.methods_to_delegate

    def initialize(*args)
      options = Applitools::Utils.extract_options!(args)
      self.runner = options[:runner]
      server_url = args.first
      @server_connector = Applitools::Connectivity::ServerConnector.new(server_url)
      ensure_config
      self.server_url = server_url if server_url
      self.disabled = false
      @viewport_size = nil
      self.match_timeout = DEFAULT_MATCH_TIMEOUT
      self.running_session = nil
      self.save_new_tests = true
      self.save_failed_tests = false
      self.remove_session_if_matching = false
      # self.agent_id = nil
      self.last_screenshot = nil
      @user_inputs = UserInputArray.new
      self.app_output_provider = Object.new
      self.verbose_results = false
      self.failed = false
      self.results = []
      @inferred_environment = nil
      @properties = []
      @server_scale = 0
      @server_remainder = 0
      get_app_output_method = ->(r, s) { get_app_output_with_screenshot r, s }

      app_output_provider.instance_eval do
        define_singleton_method :app_output do |r, s|
          get_app_output_method.call(r, s)
        end
      end

      # self.exact = nil
      self.match_level = Applitools::MatchLevel::STRICT
      self.server_scale = 0
      self.server_remainder = 0
      self.compare_with_parent_branch = false
    end

    def ensure_config
      self.config = Applitools::EyesBaseConfiguration.new
    end

    def config=(value)
      Applitools::ArgumentGuard.not_nil value, 'config'
      Applitools::ArgumentGuard.is_a? value, 'config', Applitools::EyesBaseConfiguration
      raise Applitools::EyesError, 'You can\'t use new config if eyes are opened' if open?
      @config = value
    end

    def server_connector
      @server_connector.server_url = config.server_url
      @server_connector.api_key = config.api_key
      @server_connector.proxy = config.proxy if config.proxy
      @server_connector
    end

    def full_agent_id
      if !agent_id.nil? && !agent_id.empty?
        "#{agent_id} [#{base_agent_id}]"
      else
        base_agent_id
      end
    end

    def disabled=(value)
      @disabled = Applitools::Utils.boolean_value value
    end

    def disabled?
      @disabled
    end

    def open?
      @open
    end

    def running_session?
      running_session.nil? ? false : true
    end

    def new_session?
      running_session && running_session.new_session?
    end

    def add_property(name, value)
      @properties << { name: name, value: value }
    end

    def abort_if_not_closed
      if disabled?
        logger.info "#{__method__} Ignored"
        return false
      end

      self.open = false
      self.last_screenshot = nil
      clear_user_inputs

      if running_session.nil?
        logger.info 'Closed'
        return false
      end

      logger.info 'Aborting server session...'
      server_connector.stop_session(running_session, true, false)
      logger.info '---Test aborted'

    rescue Applitools::EyesError => e
      logger.error e.message

    ensure
      self.running_session = nil
    end

    def open_base(options = {})
      self.results = []
      if disabled?
        logger.info "#{__method__} Ignored"
        return false
      end

      if open?
        abort_if_not_closed
        raise Applitools::EyesError.new 'A test is already running'
      end

      update_config_from_options(options)

      raise Applitools::EyesIllegalArgument, config.validation_errors.values.join('/n') unless config.valid?

      logger.info "Agent = #{full_agent_id}"
      logger.info "openBase(app_name: #{app_name}, test_name: #{test_name}," \
          " viewport_size: #{viewport_size})"

      raise Applitools::EyesError.new 'API key is missing! Please set it using api_key=' if
        api_key.nil? || (api_key && api_key.empty?)

      yield if block_given?

      self.open = true
    rescue Applitools::EyesError => e
      logger.error e.message
      raise e
    end

    def update_config_from_options(options)
      # Applitools::ArgumentGuard.hash options, 'open_base parameter', [:test_name]
      default_options = { session_type: 'SEQUENTIAL' }
      options = default_options.merge options

      self.app_name = options[:app_name] if options[:app_name]

      # Applitools::ArgumentGuard.not_nil options[:test_name], 'options[:test_name]'
      self.test_name = options[:test_name] if options[:test_name]
      self.viewport_size = options[:viewport_size] if options[:viewport_size]
      self.session_type = options[:session_type] if options[:session_type]
    end

    def merge_config(other_config)
      config.merge(other_config)
    end

    def ensure_running_session
      return if running_session

      logger.info 'No running session, calling start session..'
      start_session
      logger.info 'Done!'
      @match_window_task = Applitools::MatchWindowTask.new(
        logger,
        running_session,
        match_timeout,
        app_output_provider,
        server_connector
      )
    end

    def check_window_base(region_provider, retry_timeout, match_window_data)
      if disabled?
        logger.info "#{__method__} Ignored"
        result = Applitools::MatchResults.new
        result.as_expected = true
        return result
      end

      raise Applitools::EyesError.new 'Eyes not open' unless open?
      Applitools::ArgumentGuard.not_nil region_provider, 'region_provider'

      logger.info(
        "check_window_base(#{region_provider}, #{match_window_data.tag}, #{match_window_data.ignore_mismatch}," \
        " #{retry_timeout})"
      )

      tag = '' if tag.nil?

      ensure_running_session

      match_window_data.user_inputs = user_inputs

      logger.info 'Calling match_window...'
      result = @match_window_task.match_window(
        match_window_data,
        last_screenshot: last_screenshot,
        region_provider: region_provider,
        should_match_window_run_once_on_timeout: should_match_window_run_once_on_timeout,
        retry_timeout: retry_timeout
      )
      logger.info 'match_window done!'

      if result.as_expected?
        clear_user_inputs
        self.last_screenshot = result.screenshot
      else
        unless match_window_data.ignore_mismatch
          clear_user_inputs
          self.last_screenshot = result.screenshot
        end

        self.should_match_window_run_once_on_timeout = true
        self.failed = true
        logger.info "Mistmatch! #{tag}" unless running_session.new_session?

        if failure_reports == :immediate
          raise Applitools::TestFailedException.new "Mistmatch found in #{session_start_info.scenario_id_or_name}" \
              " of #{session_start_info.app_id_or_name}"
        end
      end

      logger.info 'Done!'
      result
    end

    def check_single_base(region_provider, retry_timeout, match_window_data)
      if disabled?
        logger.info "#{__method__} Ignored"
        result = Applitools::MatchResults.new
        result.as_expected = true
        return result
      end

      raise Applitools::EyesError.new 'Eyes not open' unless open?
      Applitools::ArgumentGuard.not_nil region_provider, 'region_provider'

      logger.info(
        "check_single_base(#{region_provider}, #{match_window_data.tag}, #{match_window_data.ignore_mismatch}," \
        " #{retry_timeout})"
      )

      tag = '' if tag.nil?

      session_start_info = SessionStartInfo.new agent_id: base_agent_id, app_id_or_name: app_name,
         scenario_id_or_name: test_name, batch_info: batch,
         env_name: baseline_env_name, environment: app_environment,
         default_match_settings: default_match_settings,
         branch_name: branch_name, parent_branch_name: parent_branch_name, properties: properties

      match_window_data.start_info = session_start_info
      match_window_data.update_baseline_if_new = save_new_tests
      match_window_data.update_baseline_if_different = save_failed_tests
      match_window_data.remove_session_if_matching = remove_session_if_matching
      match_window_data.scale = server_scale
      match_window_data.remainder = server_remainder

      match_window_task = Applitools::MatchSingleTask.new(
        logger,
        match_timeout,
        app_output_provider,
        server_connector
      )

      logger.info 'Calling match_window...'
      result = match_window_task.match_window(
        match_window_data,
        last_screenshot: last_screenshot,
        region_provider: region_provider,
        should_match_window_run_once_on_timeout: should_match_window_run_once_on_timeout,
        retry_timeout: retry_timeout
      ) do |match_results|
        results = match_results.original_results
        not_aborted = !results['isAborted']
        new_and_saved = results['isNew'] && save_new_tests
        different_and_saved = results['isDifferent'] && save_failed_tests
        not_a_mismatch = !results['isDifferent'] && !results['isNew']

        not_aborted && (new_and_saved || different_and_saved || not_a_mismatch)
      end
      logger.info 'match_window done!'

      if result.as_expected?
        clear_user_inputs
        self.last_screenshot = result.screenshot
      else
        unless match_window_data.ignore_mismatch
          clear_user_inputs
          self.last_screenshot = result.screenshot
        end

        self.should_match_window_run_once_on_timeout = true

        logger.info "Mistmatch! #{tag}"

        if failure_reports == :immediate
          raise Applitools::TestFailedException.new "Mistmatch found in #{session_start_info.scenario_id_or_name}" \
              " of #{session_start_info.app_id_or_name}"
        end
      end

      logger.info 'Done!'
      result.original_results
    end

    # Closes eyes
    # @param [Boolean] throw_exception If set to +true+ eyes will trow [Applitools::TestFailedError] exception,
    # otherwise the test will pass. Default is true

    def close(throw_exception = true, be_silent = false)
      if disabled?
        logger.info "#{__method__} Ignored"
        return false
      end

      logger.info "close(#{throw_exception})"
      raise Applitools::EyesError.new 'Eyes not open' unless open?

      self.open = false
      self.last_screenshot = nil

      clear_user_inputs

      unless running_session
        be_silent || logger.info('Server session was not started')
        be_silent || logger.info('--- Empty test ended')
        return Applitools::TestResults.new
      end

      is_new_session = running_session.new_session?
      session_results_url = running_session.url

      logger.info 'Ending server session...'

      save = is_new_session && save_new_tests || !is_new_session && failed && save_failed_tests

      logger.info "Automatically save test? #{save}"

      results = server_connector.stop_session running_session, false, save
      runner.aggregate_result(results) if runner

      results.is_new = is_new_session
      results.url = session_results_url

      logger.info results.to_s(verbose_results)

      if results.unresolved?
        if results.new?
          logger.error "--- New test ended. see details at #{session_results_url}"
          error_message = "New test '#{session_start_info.scenario_id_or_name}' " \
            "of '#{session_start_info.app_id_or_name}' " \
            "Please approve the baseline at #{session_results_url} "
          raise Applitools::NewTestError.new error_message, results if throw_exception
        else
          logger.error "--- Differences are found. see details at #{session_results_url}"
          error_message = "Test '#{session_start_info.scenario_id_or_name}' " \
            "of '#{session_start_info.app_id_or_name}' " \
            "detected differences! See details at #{session_results_url}"
          raise Applitools::DiffsFoundError.new error_message, results if throw_exception
        end
        return results
      end

      if results.failed?
        logger.error "--- Failed test ended. see details at #{session_results_url}"
        error_message = "Test '#{session_start_info.scenario_id_or_name}' of '#{session_start_info.app_id_or_name}' " \
            "is failed! See details at #{session_results_url}"
        raise Applitools::TestFailedError.new error_message, results if throw_exception
        return results
      end

      logger.info '--- Test passed'
      self.results.push results
      return results
    ensure
      self.running_session = nil
      self.app_name = ''
    end

    def compare_with_parent_branch=(value)
      @compare_with_parent_branch = value ? true : false
    end

    # def rendering_info
    #   server_connector.rendering_info
    # end
    #
    private

    attr_accessor :running_session, :last_screenshot, :scale_provider, :session_start_info,
      :should_match_window_run_once_on_timeout, :app_output_provider, :failed

    attr_reader :user_inputs, :properties

    private :full_agent_id, :full_agent_id=

    def dom_data
      {}
    end

    def update_default_settings(match_data)
      config.match_level_keys.each do |k|
        match_data.send("#{k}=", default_match_settings[k])
      end
    end

    def app_environment
      Applitools::AppEnvironment.new os: host_os, hosting_app: host_app,
          display_size: viewport_size, inferred: inferred_environment
    end

    def open=(value)
      @open = Applitools::Utils.boolean_value value
    end

    def clear_user_inputs
      @user_inputs.clear
    end

    def add_user_input(trigger)
      if disabled?
        logger.info "#{__method__} Ignored"
        return
      end

      Applitools::ArgumentGuard.not_nil(trigger, 'trigger')
      @user_inputs.add(trigger)
    end

    def add_text_trigger_base(control, text)
      if disabled?
        logger.info "#{__method__} Ignored"
        return
      end

      Applitools::ArgumentGuard.not_nil control, 'control'
      Applitools::ArgumentGuard.not_nil text, 'control'

      control = Applitools::Region.new control.left, control.top, control.width, control.height

      if last_screenshot.nil?
        logger.info "Ignoring '#{text}' (no screenshot)"
        return
      end

      control = last_screenshot.intersected_region control, EyesScreenshot::COORDINATE_TYPES[:context_relative],
        EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]

      if control.empty?
        logger.info "Ignoring '#{text}' out of bounds"
        return
      end

      trigger = Applitools::TextTrigger.new text, control
      add_user_input trigger
      logger.info "Added '#{trigger}'"
    end

    def add_mouse_trigger_base(action, control, cursor)
      if disabled?
        logger.info "#{__method__} Ignored"
        return
      end

      Applitools::ArgumentGuard.not_nil action, 'action'
      Applitools::ArgumentGuard.not_nil control, 'control'
      Applitools::ArgumentGuard.not_nil cursor, 'cursor'

      if last_screenshot.nil?
        logger.info "Ignoring '#{action}' (no screenshot)"
        return
      end

      cursor_in_screenshot = Applitools::Location.new cursor.x, cursor.y
      cursor_in_screenshot.offset(control)

      begin
        cursor_in_screenshot = last_screenshot.location_in_screenshot cursor_in_screenshot, CONTEXT_RELATIVE
      rescue Applitools::OutOfBoundsException
        logger.info "Ignoring #{action} (out of bounds)"
        return
      end

      control_screenshot_intersect = last_screenshot.intersected_region control, CONTEXT_RELATIVE, SCREENSHOT_AS_IS

      unless control_screenshot_intersect.empty?
        l = control_screenshot_intersect.location
        cursor_in_screenshot.offset Applitools::Location.new(-l.x, -l.y)
      end

      trigger = Applitools::MouseTrigger.new action, control_screenshot_intersect, cursor_in_screenshot
      add_user_input trigger

      logger.info "Added #{trigger}"
    end

    def start_session
      logger.info 'start_session()'

      if viewport_size
        set_viewport_size(viewport_size, true)
      else
        self.viewport_size = get_viewport_size
      end

      logger.info "Batch is #{@batch}" if @batch

      app_env = app_environment

      logger.info "Application environment is #{app_env}"

      self.session_start_info = SessionStartInfo.new agent_id: base_agent_id, app_id_or_name: app_name,
                                                scenario_id_or_name: test_name, batch_info: batch,
                                                env_name: baseline_env_name, environment: app_env,
                                                default_match_settings: default_match_settings,
                                                branch_name: branch_name, parent_branch_name: parent_branch_name,
                                                properties: properties

      logger.info 'Starting server session...'
      self.running_session = server_connector.start_session session_start_info

      logger.info "Server session ID is #{running_session.id}"
      test_info = "'#{test_name}' of '#{app_name}' #{app_env}"
      if running_session.new_session?
        logger.info "--- New test started - #{test_info}"
        self.should_match_window_run_once_on_timeout = true
      else
        logger.info "--- Test started - #{test_info}"
        self.should_match_window_run_once_on_timeout = false
      end
    end

    def get_app_output_with_screenshot(region_provider, last_screenshot)
      dom_url = ''
      captured_dom_data = dom_data
      unless captured_dom_data.empty?
        begin
          logger.info 'Processing DOM..'
          dom_url = server_connector.post_dom_json(captured_dom_data) do |json|
            io = StringIO.new
            gz = Zlib::GzipWriter.new(io)
            gz.write(json.encode('UTF-8'))
            gz.close
            result = io.string
            io.close
            result
          end
          logger.info 'Done'
          logger.info dom_url
        rescue Applitools::EyesError => e
          logger.warn e.message
          dom_url = nil
        end
      end
      logger.info 'Getting screenshot...'
      screenshot = capture_screenshot
      logger.info 'Done getting screenshot!'
      region = region_provider.region

      unless region.empty?
        screenshot = screenshot.sub_screenshot region, region_provider.coordinate_type, false
      end

      screenshot = yield(screenshot) if block_given?

      logger.info 'Compressing screenshot...'
      compress_result = compress_screenshot64 screenshot, last_screenshot
      logger.info 'Done! Getting title...'
      a_title = title
      logger.info 'Done!'
      Applitools::AppOutputWithScreenshot.new(
        Applitools::AppOutput.new(a_title, compress_result).tap do |o|
          o.location = region.location unless region.empty?
          o.dom_url = dom_url unless dom_url && dom_url.empty?
          o.screenshot_url = screenshot_url if respond_to?(:screenshot_url) && !screenshot_url.nil?
        end,
        screenshot
      )
    end

    def compress_screenshot64(screenshot, _last_screenshot)
      screenshot # it is a stub
    end

    class UserInputArray < Array
      def add(trigger)
        raise Applitools::EyesIllegalArgument.new 'trigger must be kind of Trigger!' unless trigger.is_a? Trigger
        self << trigger
      end

      def to_hash
        map do |trigger|
          trigger.to_hash if trigger.respond_to? :to_hash
        end.compact
      end
    end
  end
end
