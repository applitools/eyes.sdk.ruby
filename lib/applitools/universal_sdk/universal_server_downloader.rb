# frozen_string_literal: true

require 'open-uri'
require 'digest'
require 'fileutils'

module Applitools
  class UniversalServerDownloader
    class << self

      def download(to)
        puts "[eyes-universal] Downloading Eyes universal server from #{full_url}"
        where = filepath(to)
        full_url.open {|cloud| File.binwrite(where, cloud.read) }
        if Digest::SHA256.file(where).to_s == expected_binary_sha
          FileUtils.chmod('+x', where)
          puts "[eyes-universal] Download complete. Server placed in #{where}"
        else
          puts "[eyes-universal] Download broken. Please try reinstall"
        end
      end

      def filepath(to)
        File.expand_path(filename, to)
      end

      private

      def base_url
        "https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%40#{Applitools::UNIVERSAL_VERSION}/"
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '7c67e3c0de4adb44420849a71fdf48613ea08a7993aa80766f1dbc4fa911eace' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '7c67e3c0de4adb44420849a71fdf48613ea08a7993aa80766f1dbc4fa911eace'
          when /musl/i
            '9cbc94610b88728fbbe5f51b43a96e40bb36b686fbf6af305a1bb27ba2b172cc'
          when /linux|arch/i
            '529581f7bddc51c94ec5f9525fda65fe0cd5131c5666c7534dac8edb416094ee'
          when /darwin/i
            'e7593e0d287227a4ebf45463ee50100d3364426eede992d63b876198ecf5e98e'
          else
            raise 'Unsupported platform'
        end
      end

      def filename
        return 'eyes-universal-win.exe' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            'eyes-universal-win.exe'
          when /musl/i
            'eyes-universal-alpine'
          when /linux|arch/i
            'eyes-universal-linux'
          when /darwin/i
            'eyes-universal-macos'
          else
            raise "Unsupported platform #{RUBY_PLATFORM}"
        end
      end

    end
  end
end
