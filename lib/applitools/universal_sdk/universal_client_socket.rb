# frozen_string_literal: true

require 'faye/websocket'
require 'json'
require 'securerandom'
require 'colorize'

module Applitools::Connectivity
  class UniversalClientSocket
    attr_reader :listeners, :queue

    def initialize
      @listeners = {}
      @queue = []
    end

    def connect(uri, ws = ::Faye::WebSocket::Client.new(uri))
      @socket = ws

      queue.each {|command| command.call}
      queue.clear

      ws.on :message do |event|
        message = JSON.parse(event.data, {:symbolize_names => true})
        params = [message[:payload], message[:key]]
        find_and_execute_listeners(message[:name], message[:key], params)
      end

      ws.on :close do |event|
        find_and_execute_listeners('close')
      end
    end

    def emit(message, payload)
      command = ->() {@socket.send(serialize(message, payload))}
      @socket ? command.call : queue.push(command)
    end

    def command(name, fn)
      on(name, ->(payload, key) {
        begin
          log("[#{'COMMAND'.yellow}] #{name}, #{key}, #{JSON.pretty_generate(payload)}")
          result = fn.call(payload)
          emit({name: name, key: key}, {result: result})
        rescue => error
          log("[#{'COMMAND ERROR'.red}] #{error}")
          emit({name: name, key: key}, error.message || error)
        end
      })
    end

    def request(name, payload, cb = nil, key = SecureRandom.uuid)
      log("[#{'REQUEST'.blue}] #{name}, #{key}, #{JSON.pretty_generate(payload)}")
      emit({name: name, key: key}, payload)
      once({name: name, key: key}, Proc.new {|result|
        cb.call(result[:result] || result[:error] || true) if cb
      })
    end

    private

    def find_and_execute_listeners(name, key = nil, params = [])
      name_with_key = "#{name}/#{key}"
      fns = listeners[name.to_sym]
      fns = listeners[name_with_key.to_sym] if (!fns)
      return if (!fns)
      fns.each {|fn| fn.call(*params)}
    end

    def serialize(type, payload)
      message = type.is_a?(String) ?
        {:name => type, :payload => payload} : {:name => type[:name], key: type[:key], :payload => payload}
      JSON.generate(message)
    end

    def get_name_from_type(type)
      type.is_a?(String) ? type : "#{type[:name]}/#{type[:key]}"
    end

    def on(type, fn)
      name = get_name_from_type(type)
      fns = listeners[name.to_sym]
      if (!fns)
        fns = []
        listeners[name.to_sym] = fns
      end
      fns.push(fn)
    end

    def off(type)
      name = get_name_from_type(type)
      listeners.delete(name.to_sym)
    end

    def once(type, fn)
      on(type, ->(*args) {
        fn.call(*args)
        off(type)
      })
    end

    def log(message)
      if ENV['APPLITOOLS_SHOW_UNIVERSAL_LOGS']
        Applitools::EyesLogger.logger.debug message
      end
    end

  end
end
# U-Notes : Added internal Applitools::Connectivity::UniversalClientSocket
