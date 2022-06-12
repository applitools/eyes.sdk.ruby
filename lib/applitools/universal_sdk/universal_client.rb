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

    SESSION_INIT = 'Core.makeSDK'

    CORE_MAKE_MANAGER = 'Core.makeManager'
    CORE_GET_VIEWPORT_SIZE = 'Core.getViewportSize'
    CORE_SET_VIEWPORT_SIZE = 'Core.setViewportSize'
    CORE_CLOSE_BATCHES = 'Core.closeBatches'
    CORE_DELETE_TEST = 'Core.deleteTest'

    EYES_MANAGER_MAKE_EYES = 'EyesManager.openEyes'
    EYES_MANAGER_CLOSE_ALL_EYES = 'EyesManager.closeManager'
    EYES_CHECK = 'Eyes.check'
    EYES_LOCATE = 'Eyes.locate'
    EYES_EXTRACT_TEXT_REGIONS = 'Eyes.extractTextRegions'
    EYES_EXTRACT_TEXT = 'Eyes.extractText'
    EYES_CLOSE = 'Eyes.close'
    EYES_ABORT = 'Eyes.abort'


    def initialize
      # @socket = Applitools::Connectivity::UniversalClientSocket.new
      prepare_socket
      # store on open for next check calls
      @open_config = nil
    end

    def make_manager(eyes_manager_config)
      Applitools::EyesLogger.logger.debug "EyesManager config: #{eyes_manager_config}"
      eyes_manager = core_make_manager(eyes_manager_config)
      Applitools::EyesLogger.logger.debug "EyesManager applitools-ref-id: #{eyes_manager[:"applitools-ref-id"]}"
      Applitools::UniversalEyesManager.new(eyes_manager, self)
    end


    def core_make_manager(eyes_manager_config)
      # await(->(cb) { @socket.request(CORE_MAKE_MANAGER, eyes_manager_config, cb) })
      command_with_result(CORE_MAKE_MANAGER, eyes_manager_config)
    end

    def eyes_manager_make_eyes(manager, driver_config, config)
      @open_config = config

      # await(->(cb) {
      #   @socket.request(EYES_MANAGER_MAKE_EYES, {manager: manager, driver: driver_config, config: config}, cb)
      # })
      command_with_result(EYES_MANAGER_MAKE_EYES, {manager: manager, driver: driver_config, config: config})
    end

    def eyes_manager_close_all_eyes(manager)
      # await(->(cb) { @socket.request(EYES_MANAGER_CLOSE_ALL_EYES, {manager: manager}, cb) })
      command_with_result(EYES_MANAGER_CLOSE_ALL_EYES, {manager: manager})
    end

    def eyes_check(eyes, settings)
      # await(->(cb) { @socket.request(EYES_CHECK, {eyes: eyes, settings: settings, config: @open_config}, cb) })
      command_with_result(EYES_CHECK, {eyes: eyes, settings: settings, config: @open_config})
    end

    def eyes_locate(eyes, settings)
      # await(->(cb) { @socket.request(EYES_LOCATE, {eyes: eyes, settings: settings, config: @open_config}, cb) })
      command_with_result(EYES_LOCATE, {eyes: eyes, settings: settings, config: @open_config})
    end

    def eyes_extract_text_regions(eyes, settings)
      # await(->(cb) { @socket.request(EYES_EXTRACT_TEXT_REGIONS, {eyes: eyes, settings: settings, config: @open_config}, cb) })
      command_with_result(EYES_EXTRACT_TEXT_REGIONS, {eyes: eyes, settings: settings, config: @open_config})
    end

    def eyes_extract_text(eyes, regions)
      # await(->(cb) { @socket.request(EYES_EXTRACT_TEXT, {eyes: eyes, regions: regions, config: @open_config}, cb) })
      command_with_result(EYES_EXTRACT_TEXT, {eyes: eyes, regions: regions, config: @open_config})
    end

    def eyes_close(eyes)
      # await(->(cb) { @socket.request(EYES_CLOSE, {eyes: eyes}, cb) })
      command_with_result(EYES_CLOSE, {eyes: eyes})
    end

    def eyes_abort(eyes)
      # await(->(cb) { @socket.request(EYES_ABORT, {eyes: eyes}, cb) })
      command_with_result(EYES_ABORT, {eyes: eyes})
    end

    def core_get_viewport_size(driver)
      # await(->(cb) { @socket.request(CORE_GET_VIEWPORT_SIZE, {driver: driver}, cb) })
      command_with_result(CORE_GET_VIEWPORT_SIZE, {driver: driver})
    end

    def core_set_viewport_size(driver, size)
      # await(->(cb) { @socket.request(CORE_SET_VIEWPORT_SIZE, {driver: driver, size: size}, cb) })
      command_with_result(CORE_SET_VIEWPORT_SIZE, {driver: driver, size: size})
    end

    def core_close_batches(close_batch_settings=nil)
      # batchIds, serverUrl?, apiKey?, proxy?
      unless close_batch_settings.is_a?(Hash)
        batch_ids = [@open_config[:batch][:id]]
        batch_ids = [close_batch_settings] if close_batch_settings.is_a?(String)
        batch_ids = close_batch_settings if close_batch_settings.is_a?(Array)
        optional = [:serverUrl, :apiKey, :proxy].map {|k| [k, @open_config[k]] }.to_h
        close_batch_settings = { settings: ({ batchIds: batch_ids }.merge(optional).compact) }
      end
      # await(->(cb) { @socket.request(CORE_CLOSE_BATCHES, close_batch_settings, cb) })
      command_with_result(CORE_CLOSE_BATCHES, close_batch_settings)
    end

    def core_delete_test(delete_test_settings)
      # testId, batchId, secretToken, serverUrl, apiKey?, proxy?
      # await(->(cb) { @socket.request(CORE_DELETE_TEST, delete_test_settings, cb) })
      command_with_result(CORE_DELETE_TEST, delete_test_settings)
    end


    private


    def prepare_socket
      @web_socket = ::Applitools::Connectivity::UniversalServer.check_or_run
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
      ip = @web_socket.remote_address.ip_address
      port = @web_socket.remote_address.ip_port
      socket_uri = "ws://#{ip}:#{port}/eyes"
      handshake = WebSocket::Handshake::Client.new(url: socket_uri)
      @web_socket.write(handshake)
      web_socket_result = receive_result('handshake')
      handshake << web_socket_result
      @handshake_version = handshake.version if handshake.finished? && handshake.valid?
    end

    def session_init
      command(SESSION_INIT, {
        name: :rb,
        version: Applitools::VERSION,
        protocol: :webdriver,
        cwd: Dir.pwd
      })
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
        web_socket_result = @web_socket.recvmsg.first
        # web_socket_result = @web_socket.read_nonblock(WebSocket.max_frame_size)
        # web_socket_result = @web_socket.readpartial(WebSocket.max_frame_size)
      rescue IO::WaitReadable
        if IO.select([@web_socket], nil, nil, timeout)
          retry
        else
          raise Applitools::EyesError.new "Stuck on waiting #{name}"
        end
      end
      raise Applitools::EyesError.new "Empty result on #{name}" if web_socket_result.empty?

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
        result = receive_result(name)
      elsif  incoming_json['name'] === name && incoming_json['key'] === key
        incoming_payload = incoming_json['payload']
        result = incoming_payload.key?('error') ? incoming_payload['error'] : incoming_payload['result']
        Applitools::Utils.deep_symbolize_keys result
      else
        # require 'pry'
        # binding.pry
        raise Applitools::EyesError.new "Result mismatch : #{name} #{key} (#{incoming_json['name']} #{incoming_json['key']})"
      end
    end

    def command_with_result name, payload, key = SecureRandom.uuid
      command(name, payload, key)
      web_socket_result = receive_result(name)
      format_result(name, key, web_socket_result)
    end

  end
end
# U-Notes : Added internal Applitools::Connectivity::UniversalClient