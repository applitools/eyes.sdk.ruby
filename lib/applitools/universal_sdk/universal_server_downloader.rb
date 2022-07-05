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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.9.5/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '7b705b237f0dd0f49f6bcd8c0e8d4a3a062d0dc335e21bc51b1923d19f4d69c2' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '7b705b237f0dd0f49f6bcd8c0e8d4a3a062d0dc335e21bc51b1923d19f4d69c2'
          when /musl/i
            'b59656b75cef51ad17c7270ab1746be62e8145705c43363c095b633d332049dc'
          when /linux|arch/i
            'd8bb764a11bdd14d44f51ec4cf855c774988e941d83ccb817afef698b839719c'
          when /darwin/i
            '86e42c6c41e4bb975726b135f38f5398279362655cf41f81d2cc1ac84bba4a47'
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
