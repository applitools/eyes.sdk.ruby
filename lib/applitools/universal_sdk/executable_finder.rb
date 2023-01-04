# frozen_string_literal: true

module Applitools::Connectivity
  module UniversalServerGemFinder
    extend self

    SERVER_GEM_NAME = 'eyes_universal'

    def filepath
      server_lib ? File.join(server_lib.gem_dir, 'ext', 'eyes-universal', filename) : ''
    end

    def executable_filepath
      raise 'Universal server unrecognized' unless File.exist?(filepath) && File.executable?(filepath)
      filepath
    end

    private

    def server_lib
      Gem::Specification.find_by_name(SERVER_GEM_NAME)
    rescue Gem::MissingSpecError
      nil
    end

    def filename
      return 'eyes-universal-win.exe' if Gem.win_platform?
      case RUBY_PLATFORM
        when /darwin/i
          'eyes-universal-macos'
        when /arm/i
          'eyes-universal-linux-arm64'
        when /mswin|windows|mingw/i
          'eyes-universal-win.exe'
        when /musl/i
          'eyes-universal-alpine'
        when /linux|arch/i
          'eyes-universal-linux'
        else
          raise 'Unsupported platform'
      end
    end

  end
end
