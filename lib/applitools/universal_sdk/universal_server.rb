# frozen_string_literal: true

require 'open-uri'
require 'digest'
require 'fileutils'

module Applitools::Connectivity
  module UniversalServer
    extend self

    DEFAULT_SERVER_IP = '127.0.0.1'
    DEFAULT_SERVER_PORT = 21077

    def run
      puts find_server_file?
      puts filepath
      raise 'Universal server unrecognized' unless find_server_file?
      pid = spawn(filepath, '--singleton --lazy', [:out, :err] => ["log", 'w'])
      puts pid
      Process.detach(pid)
    end

    def confirm_is_up(ip, port, attempt = 1)
      raise 'Universal server unavailable' if (attempt === 16)
      begin
        TCPSocket.new(ip, port)
      rescue Errno::ECONNREFUSED
        sleep 1
        confirm_is_up(ip, port, attempt + 1)
      end
    end

    def check_or_run(ip = DEFAULT_SERVER_IP, port = DEFAULT_SERVER_PORT)
      server_uri = "#{ip}:#{port}"
      socket_uri = "ws://#{server_uri}/eyes"
      begin
        TCPSocket.new(ip, port)
        msg = "Connect to #{server_uri}"
      rescue Errno::ECONNREFUSED
        run
        confirm_is_up(ip, port)
        msg = "Connect to #{server_libname} : #{filename}"
      end

      Applitools::EyesLogger.logger.debug(msg) if ENV['APPLITOOLS_SHOW_LOGS']
      socket_uri
    end

    private

    def filename
      case RUBY_PLATFORM
        when /mswin|windows/i
          'eyes-universal-win.exe'
        when /linux|arch/i
          'eyes-universal-linux'
        when /darwin/i
          'eyes-universal-macos'
        else
          raise 'Unsupported platform'
      end
    end

    def server_libname
      'eyes_universal'
    end

    def server_lib
      Gem::Specification.find_by_name(server_libname)
    rescue Gem::MissingSpecError
      nil
    end

    def filepath
      server_lib ? File.join(server_lib.gem_dir, 'ext', 'eyes-universal', filename) : ''
    end

    def find_server_file?
      File.exist?(filepath) && File.executable?(filepath)
    end

  end
end
# U-Notes : Added internal Applitools::Connectivity::UniversalServer
