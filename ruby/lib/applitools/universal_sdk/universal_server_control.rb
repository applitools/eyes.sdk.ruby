# frozen_string_literal: true

require 'singleton'

module Applitools::Connectivity
  class UniversalServerControl

    include Singleton

    DEFAULT_SERVER_IP = '127.0.0.1'
    EXECUTABLE_FILEPATH = Applitools::Connectivity::UniversalServerGemFinder.executable_filepath

    def initialize
      @control_pipe = nil
      @port_pipe = nil
      @usdk_pid = nil
      @monitoring_thread = nil
      @port = nil
      start_server_with_pipe
      @sockets = []
    end

    def server_port
      @port
    end

    def new_server_socket_connection
      begin
        socket = TCPSocket.new(DEFAULT_SERVER_IP, @port)
        @sockets.push(socket)
        socket
      rescue Errno::ECONNREFUSED
        nil
      end
    end

    def server_running?
      return false if @monitoring_thread.nil?
      monitoring_result = @monitoring_thread.join(1)
      monitoring_result.nil?
    end

    def stop_server
      return if @control_pipe.nil?
      @control_pipe.close_write
      @sockets.each {|socket| socket.close unless socket.closed? }
      sleep(1)
    end

    def to_s # for test & debug
      "SDKServer(port=#{@port}; pid=#{@usdk_pid})"
    end

    private

    def start_server_with_pipe
      in_pipe, @control_pipe = IO.pipe
      @port_pipe, port_w = IO.pipe

      @usdk_pid = spawn(
        EXECUTABLE_FILEPATH, '--no-singleton', '--shutdown-mode', 'stdin',
        in: in_pipe, out: port_w, err: port_w,
        # close_others: true
      )
      in_pipe.close_read
      port_w.close_write

      @monitoring_thread = Process.detach(@usdk_pid)

      @port = @port_pipe.readline.strip.to_i
      @port_pipe.close_read

      if ENV['APPLITOOLS_SHOW_LOGS']
        Applitools::EyesLogger.logger.debug("Started Universal SDK server at #{@port} pid = #{@usdk_pid}")
      end
    end

  end
end
