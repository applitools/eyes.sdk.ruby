# frozen_string_literal: true

require 'open-uri'
require 'digest'
require 'fileutils'

module Applitools::Connectivity
  module UniversalServer
    extend self

    DEFAULT_SERVER_IP = '127.0.0.1'
    DEFAULT_SERVER_PORT = 2107

    def run
      pid = spawn(filepath, '--singleton --lazy', [:out, :err] => ["log", 'w'])
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
        msg = "Connect to #{server_libname}"
      end

      Applitools::EyesLogger.logger.debug(msg) if ENV['APPLITOOLS_SHOW_LOGS']
      socket_uri
    end

    private

    def expected_binary_sha
      case RUBY_PLATFORM
        when /mswin|windows/i
          '4145facec859dc81511da924f0aa2cd91cfb3db36c445715f3555465b48c2d45'
        when /linux|arch/i
          '6f559b9de46c9462e82aab80b6b77ff8fa8b31009082fec14e75fab5b097c5a4'
        when /darwin/i
          'ebc85cfcaadce161f4c0db9007f8d8a4fae8dcc17b59059a37ebbcee86c32677'
        else
          raise 'Unsupported platform'
      end
    end

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
      case RUBY_PLATFORM
        when /mswin|windows/i
          'eyes_universal-win'
        when /linux|arch/i
          'eyes_universal'
        when /darwin/i
          'eyes_universal-osx'
        else
          raise 'Unsupported platform'
      end
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
      File.exist?(filepath) && Digest::SHA256.file(filepath).to_s == expected_binary_sha && File.executable?(filepath)
    end

  end
end
# U-Notes : Added internal Applitools::Connectivity::UniversalServer
