# frozen_string_literal: true

require 'eventmachine'

# require_relative 'universal_client_socket'
# require_relative 'universal_eyes_manager'

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


    def initialize(queue = EM::Queue.new)
      @socket = Applitools::Connectivity::UniversalClientSocket.new
      @queue = queue
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
      await(->(cb) { @socket.request(CORE_MAKE_MANAGER, eyes_manager_config, cb) })
    end

    def eyes_manager_make_eyes(manager, driver_config, config)
      @open_config = config

      await(->(cb) {
        @socket.request(EYES_MANAGER_MAKE_EYES, {manager: manager, driver: driver_config, config: config}, cb)
      })
    end

    def eyes_manager_close_all_eyes(manager)
      await(->(cb) { @socket.request(EYES_MANAGER_CLOSE_ALL_EYES, {manager: manager}, cb) })
    end

    def eyes_check(eyes, settings)
      await(->(cb) { @socket.request(EYES_CHECK, {eyes: eyes, settings: settings, config: @open_config}, cb) })
    end

    def eyes_locate(eyes, settings)
      await(->(cb) { @socket.request(EYES_LOCATE, {eyes: eyes, settings: settings, config: @open_config}, cb) })
    end

    def eyes_extract_text_regions(eyes, settings)
      await(->(cb) { @socket.request(EYES_EXTRACT_TEXT_REGIONS, {eyes: eyes, settings: settings, config: @open_config}, cb) })
    end

    def eyes_extract_text(eyes, regions)
      await(->(cb) { @socket.request(EYES_EXTRACT_TEXT, {eyes: eyes, regions: regions, config: @open_config}, cb) })
    end

    def eyes_close(eyes)
      await(->(cb) { @socket.request(EYES_CLOSE, {eyes: eyes}, cb) })
    end

    def eyes_abort(eyes)
      await(->(cb) { @socket.request(EYES_ABORT, {eyes: eyes}, cb) })
    end

    def core_get_viewport_size(driver)
      await(->(cb) { @socket.request(CORE_GET_VIEWPORT_SIZE, {driver: driver}, cb) })
    end

    def core_set_viewport_size(driver, size)
      await(->(cb) { @socket.request(CORE_SET_VIEWPORT_SIZE, {driver: driver, size: size}, cb) })
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
      await(->(cb) { @socket.request(CORE_CLOSE_BATCHES, close_batch_settings, cb) })
    end

    def core_delete_test(delete_test_settings)
      # testId, batchId, secretToken, serverUrl, apiKey?, proxy?
      await(->(cb) { @socket.request(CORE_DELETE_TEST, delete_test_settings, cb) })
    end


    private


    def prepare_socket
      socket_uri = ::Applitools::Connectivity::UniversalServer.check_or_run
      connect_and_configure_socket(socket_uri)
    end

    def connect_and_configure_socket(uri)
      Thread.new do
        EM.run do
          @socket.connect(uri)
          @socket.emit(SESSION_INIT, {
            name: :rb,
            version: ::Applitools::VERSION,
            protocol: :webdriver,
            cwd: Dir.pwd
          })
        end
      end
    end

    def await(function)
      resolved = false
      cb = ->(result) {
        resolved = result
      }
      @queue.push(function)
      @queue.pop {|fn| fn.call(cb)}
      sleep 1 until !!resolved
      resolved
    end

  end
end
# U-Notes : Added internal Applitools::Connectivity::UniversalClient