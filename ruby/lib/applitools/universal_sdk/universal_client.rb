# frozen_string_literal: true

# require_relative 'universal_client_socket'
# require_relative 'universal_eyes_manager'

require 'json'
require 'securerandom'
require 'colorize'
require 'websocket'
require 'uri'


module Applitools::Connectivity
  class UniversalClient

    extend Forwardable
    def_delegators 'Applitools::EyesLogger', :logger

    SESSION_INIT = 'Core.makeCore'

    CORE_MAKE_MANAGER = 'Core.makeManager'
    CORE_GET_VIEWPORT_SIZE = 'Core.getViewportSize'
    CORE_SET_VIEWPORT_SIZE = 'Core.setViewportSize'
    CORE_CLOSE_BATCHES = 'Core.closeBatch'
    CORE_DELETE_TEST = 'Core.deleteTest'

    EYES_MANAGER_MAKE_EYES = 'EyesManager.openEyes'
    EYES_MANAGER_CLOSE_ALL_EYES = 'EyesManager.closeManager'
    EYES_CHECK = 'Eyes.check'
    EYES_CHECK_AND_CLOSE = 'Eyes.checkAndClose' # ...
    EYES_LOCATE = 'Core.locate'
    EYES_EXTRACT_TEXT_REGIONS = 'Eyes.locateText'
    EYES_EXTRACT_TEXT = 'Eyes.extractText'
    EYES_CLOSE = 'Eyes.close'
    EYES_ABORT = 'Eyes.abort'

    attr_accessor :commands_config

    def initialize
      # @socket = Applitools::Connectivity::UniversalClientSocket.new
      prepare_socket
      # store on open for next check calls
      @open_config = nil
      @commands_config = {
        open: {},
        screenshot: {},
        check: {},
        close: {}
      }
    end

    def make_manager(eyes_manager_config)
      Applitools::EyesLogger.logger.debug "EyesManager config: #{eyes_manager_config}"
      eyes_manager = core_make_manager(eyes_manager_config)
      Applitools::EyesLogger.logger.debug "EyesManager applitools-ref-id: #{eyes_manager[:"applitools-ref-id"]}"
      Applitools::UniversalEyesManager.new(eyes_manager, self)
    end


    def core_make_manager(eyes_manager_config)
      # interface MakeManagerRequestPayload {
      #   type: 'ufg' | 'classic'
      #   concurrency?: number
      #   legacyConcurrency?: number
      #   agentId?: string
      # }
      #
      # type MakeManagerResponsePayload = Ref<EyesManager>
      command_with_result(CORE_MAKE_MANAGER, eyes_manager_config)
    end

    def config_mapping(old_config, command_config, name)
      return if old_config[name].nil?
      command_config[name] = old_config.delete(name)
    end

    def map_open_eyes_config_to_commands_config(config)
      [
        :serverUrl, :apiKey, :proxy, :connectionTimeout, :removeSession, :agentId, :appName, :testName, :displayName,
        :userTestId, :sessionType, :properties, :batch, :keepBatchOpen, :environmentName, :environment, :branchName,
        :parentBranchName, :baselineEnvName, :baselineBranchName, :compareWithParentBranch, :ignoreBaseline,
        :ignoreGitBranching, :saveDiffs, :abortIdleTestTimeout
      ].each do |k|
        config_mapping(config, commands_config[:open], k)
      end

      commands_config[:open][:keepBatchOpen] = config.delete(:dontCloseBatches) unless config[:dontCloseBatches].nil?

      [:hideCaret, :hideScrollbars, :disableBrowserFetching, :sendDom, :stitchMode,
       :layoutBreakpoints, :waitBeforeCapture].each do |k|
        config_mapping(config, commands_config[:check], k)
      end

      commands_config[:check][:renderers] = config.delete(:browsersInfo) unless config[:browsersInfo].nil?

      unless config[:defaultMatchSettings].nil?
        if config[:defaultMatchSettings][:accessibilitySettings]
          commands_config[:check][:accessibilitySettings] = {}
          commands_config[:check][:accessibilitySettings][:level] = config[:defaultMatchSettings][:accessibilitySettings].delete(:level) unless config[:defaultMatchSettings][:accessibilitySettings][:level].nil?
          commands_config[:check][:accessibilitySettings][:version] = config[:defaultMatchSettings][:accessibilitySettings].delete(:guidelinesVersion) unless config[:defaultMatchSettings][:accessibilitySettings][:guidelinesVersion].nil?
          config[:defaultMatchSettings].delete(:accessibilitySettings) if config[:defaultMatchSettings][:accessibilitySettings].empty?
        end
        commands_config[:check][:ignoreCaret] = config[:defaultMatchSettings].delete(:ignoreCaret) unless config[:defaultMatchSettings][:ignoreCaret].nil?
        commands_config[:check][:matchLevel] = config[:defaultMatchSettings].delete(:matchLevel) unless config[:defaultMatchSettings][:matchLevel].nil?
        config.delete(:defaultMatchSettings) if config[:defaultMatchSettings].empty?
      end

      if commands_config[:check][:fully].nil?
        commands_config[:check][:fully] = config.delete(:forceFullPageScreenshot) unless config[:forceFullPageScreenshot].nil?
      end

      commands_config[:close][:updateBaselineIfNew] = config.delete(:saveNewTests) unless config[:saveNewTests].nil?
      commands_config[:close][:updateBaselineIfDifferent] = config.delete(:saveFailedTests) unless config[:saveFailedTests].nil?

      commands_config[:screenshot] = commands_config[:check]
    end




    def eyes_manager_make_eyes(manager, driver_config, config)
      @open_config = config

      map_open_eyes_config_to_commands_config(config)
      # interface OpenEyesRequestPayload {
      #   manager: Ref<EyesManager>
      #   target?: DriverTarget
      #   settings?: OpenSettings
      #   config?: Config
      # }
      #
      # type OpenEyesResponsePayload = Ref<Eyes>
      command_with_result(EYES_MANAGER_MAKE_EYES, {manager: manager, target: driver_config, settings: commands_config[:open], config: commands_config})
    end

    def eyes_manager_close_all_eyes(manager)
      # interface CloseManagerRequestPayload {
      #   manager: Ref<EyesManager>
      #   settings?: {throwErr?: boolean}
      # }
      #
      # interface CloseManagerResponsePayload {
      #   results: Array<{
      #     error?: Error
      #     result?: TestResult
      #     renderer?: TType extends 'ufg' ? Renderer : never
      #     userTestId: string
      #   }>
      #   passed: number
      #   unresolved: number
      #   failed: number
      #   exceptions: number
      #   mismatches: number
      #   missing: number
      #   matches: number
      # }
      command_with_result(EYES_MANAGER_CLOSE_ALL_EYES, {manager: manager, config: commands_config})
    end

    def eyes_check(eyes, settings, image_target = {})
      # interface CheckRequestPayload {
      #   eyes: Ref<Eyes>
      #   target?: ImageTarget | DriverTarget
      #   settings?: CheckSettings
      #   config?: Config
      # }
      #
      # type CheckResponsePayload = CheckResult[]
      payload = {eyes: eyes, settings: settings, config: commands_config}
      payload[:target] = image_target unless image_target.empty?
      command_with_result(EYES_CHECK, payload)
    end

    def eyes_locate(eyes, settings, driver_target)
      # interface LocateRequestPayload {
      #   target?: ImageTarget | DriverTarget
      #   settings?: LocateSettings
      #   config?: Config
      # }
      #
      # interface LocateResponsePayload {
      #   [key: string]: Array<{x: number, y: number, width: number, height: number}>
      # }

      command_with_result(EYES_LOCATE, {target: driver_target, settings: settings, config: commands_config})
    end

    def eyes_extract_text_regions(eyes, settings, driver_target)
      # interface LocateTextRequestPayload {
      #   eyes: Ref<Eyes>
      #   target?: ImageTarget | DriverTarget
      #   settings?: LocateTextSettings
      #   config?: Config
      # }
      #
      # type LocateTextResponcePayload = Record<string, Array<{text: string, x: number, y: number, width: number, hieght: number}>>
      payload = {eyes: eyes, target: driver_target, settings: settings, config: commands_config}
      payload.delete(:target) if driver_target.nil? || driver_target.empty?
      command_with_result(EYES_EXTRACT_TEXT_REGIONS, payload)
    end

    def eyes_extract_text(eyes, regions, driver_target)
      # interface ExtractTextRequestPayload {
      #   eyes: Ref<Eyes>
      #   target?: ImageTarget | DriverTarget
      #   settings?: ExtractTextSettings | ExtractTextSettings[]
      #   config?: Config
      # }
      #
      # type ExtractTextResponcePayload = string[]
      payload = {eyes: eyes, target: driver_target, settings: regions, config: commands_config}
      payload.delete(:settings) if regions.empty?
      command_with_result(EYES_EXTRACT_TEXT, payload)
    end

    def eyes_close(eyes)
      # interface CloseResponsePayload {
      #   eyes: Ref<Eyes>
      #   settings?: CloseSettings
      #   config?: Config
      # }
      #
      # type CloseResponsePayload = TestResult[]
      settings = {throwErr: false}

      command_with_result(EYES_CLOSE, {eyes: eyes, settings: settings, config: commands_config})
    end

    def eyes_abort(eyes)
      # interface AbortPayload {
      #   eyes: Ref<Eyes>
      # }
      #
      # type AbortResponsePayload = TestResult[]
      command_with_result(EYES_ABORT, {eyes: eyes})
    end

    def core_get_viewport_size(driver)
      # interface GetViewportSizeRequestPayload {
      #   target: DriverTarget
      # }
      #
      # interface GetViewportSizeResponsePayload {
      #   width: number
      #   height: number
      # }
      command_with_result(CORE_GET_VIEWPORT_SIZE, {target: driver})
    end

    def core_set_viewport_size(driver, size)
      # interface SetViewportSizeRequestPayload {
      #   target: DriverTarget
      #   size: {width: number, height: number}
      # }
      command_with_result(CORE_SET_VIEWPORT_SIZE, {target: driver, size: size})
    end

    def core_close_batches(close_batch_settings=nil)
      # interface CloseBatchRequestPayload {
      #   settings: CloseBatchSettings | CloseBatchSettings[]
      # }
      unless close_batch_settings.is_a?(Hash)
        batch_ids = [@open_config[:batch][:id]]
        batch_ids = [close_batch_settings] if close_batch_settings.is_a?(String)
        batch_ids = close_batch_settings if close_batch_settings.is_a?(Array)
        optional = [:serverUrl, :apiKey, :proxy].map {|k| [k, @open_config[k]] }.to_h
        close_batch_settings = { settings: ({ batchIds: batch_ids }.merge(optional).compact) }
      end
      command_with_result(CORE_CLOSE_BATCHES, close_batch_settings)
    end

    def core_delete_test(delete_test_settings)
      # interface DeleteTestRequestPayload {
      #   settings: DeleteTestSettings | DeleteTestSettings[]
      # }
      command_with_result(CORE_DELETE_TEST, delete_test_settings)
    end


    private


    def prepare_socket
      @universal_server_control = Applitools::Connectivity::UniversalServerControl.instance
      @web_socket = @universal_server_control.new_server_socket_connection
      socket_handshake
      session_init
      # connect_and_configure_socket(socket_uri)
    end

    # def prepare_socket
    #   socket_uri = ::Applitools::Connectivity::UniversalServer.check_or_run
    #   connect_and_configure_socket(socket_uri)
    # end
    #
    # def connect_and_configure_socket(uri)
    #   @socket.connect(uri)
    #   @socket.emit(SESSION_INIT, {
    #     name: :rb,
    #     version: ::Applitools::VERSION,
    #     protocol: :webdriver,
    #     cwd: Dir.pwd
    #   })
    # end
    #
    # def await(function)
    #   resolved = false
    #   cb = ->(result) {
    #     resolved = result
    #   }
    #   function.call(cb)
    #   sleep 1 until !!resolved
    #   resolved
    # end


    def socket_handshake
      socket_uri = "ws://#{@web_socket.remote_address.inspect_sockaddr}/eyes"
      handshake = WebSocket::Handshake::Client.new(url: socket_uri)
      @web_socket.write(handshake)
      web_socket_result = receive_result('handshake')
      handshake << web_socket_result
      @handshake_version = handshake.version if handshake.finished? && handshake.valid?
    end

    def session_init
      make_core_payload = {
        name: :rb,
        version: Applitools::VERSION,
        protocol: :webdriver,
        cwd: Dir.pwd
      }
      command(SESSION_INIT, make_core_payload)
      # no response
    end

    def command(name, payload, key = SecureRandom.uuid)
      json_data = JSON.generate({name: name, key: key, payload: payload})
      outgoing_frame = WebSocket::Frame::Outgoing::Client.new(version: @handshake_version, data: json_data, type: :text)
      @web_socket.write(outgoing_frame)
    end

    def receive_result(name)
      timeout = 5 * 60 # seconds
      begin
        # web_socket_result = @web_socket.recvmsg.first
        # web_socket_result = @web_socket.read_nonblock(WebSocket.max_frame_size)
        web_socket_result = @web_socket.readpartial(WebSocket.max_frame_size)
      rescue IO::WaitReadable
        if IO.select([@web_socket], nil, nil, timeout)
          retry
        else
          raise Applitools::EyesError.new "Stuck on waiting #{name}"
        end
      end
      raise Applitools::EyesError.new "Empty result on #{name}" if web_socket_result.empty?

      web_socket_result += receive_result(name) if @web_socket.ready?
      web_socket_result
    end

    def format_result(name, key, web_socket_result)
      encoded_frame = WebSocket::Frame::Incoming::Client.new(version: @handshake_version)
      encoded_frame << web_socket_result
      decoded_frame = encoded_frame.next
      incoming_json = JSON.parse(decoded_frame.to_s)
      if incoming_json['name'] === 'Server.log'
        incoming_payload = incoming_json['payload']
        # incoming_payload['level']
        puts incoming_payload['message']
        new_web_socket_result = receive_result(name)
        result = format_result(name, key, new_web_socket_result)
      elsif  incoming_json['name'] === name && incoming_json['key'] === key
        incoming_payload = incoming_json['payload']
        result = incoming_payload.key?('error') ? incoming_payload['error'] : incoming_payload['result']
        Applitools::Utils.deep_symbolize_keys result
      elsif incoming_json.nil?
        raise Applitools::EyesError.new "Result nil : #{name} #{key} (#{decoded_frame} #{encoded_frame})"
      else
        # require 'pry'
        # binding.pry
        raise Applitools::EyesError.new "Result mismatch : #{name} #{key} (#{incoming_json['name']} #{incoming_json['key']})"
      end
    end

    def get_command_result(name, key)
      web_socket_result = receive_result(name)
      results = convert_web_socket_result(web_socket_result)

      this_key_responses, other_responses = results.partition {|h| h['name'] === name && h['key'] === key}
      process_other_responses other_responses

      if this_key_responses.empty?
        get_command_result(name, key)
      elsif this_key_responses.size === 1
        convert_responses(this_key_responses)
      else # size > 1
        raise Applitools::EyesError.new "Result mismatch : #{name} #{key} (#{this_key_responses})"
      end
    end

    def convert_web_socket_result(web_socket_result)
      encoded_frame = WebSocket::Frame::Incoming::Client.new(version: @handshake_version)
      encoded_frame << web_socket_result
      decoded_frames = []
      until (decoded_frame = encoded_frame.next).nil?
        decoded_frames.push(decoded_frame)
      end
      decoded_frames.map {|frame| JSON.parse(frame.to_s)}
    end

    def process_other_responses(other_responses)
      other_responses.each do |incoming_json|
        if incoming_json['name'] === 'Server.log'
          if ENV['APPLITOOLS_SHOW_UNIVERSAL_LOGS']
            Applitools::EyesLogger.logger.debug "[Server.log] #{incoming_json['payload']['message']}"
          end
        else
          Applitools::EyesLogger.logger.info "[Server.info] #{incoming_json}"
        end
      end
    end

    def convert_responses(one_response_array)
      incoming_json = one_response_array.first
      incoming_payload = incoming_json['payload']
      result = incoming_payload.key?('error') ? incoming_payload['error'] : incoming_payload['result']
      Applitools::Utils.deep_symbolize_keys result
    end

    def command_with_result name, payload, key = SecureRandom.uuid
      command(name, payload, key)
      get_command_result(name, key)
    end

  end
end
# U-Notes : Added internal Applitools::Connectivity::UniversalClient