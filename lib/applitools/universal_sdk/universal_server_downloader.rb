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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.8.0/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '6c7f6035bd0489f94e5814ae33ec4ac01d4e10b2f3eb9cf1947aa7a7062aa5a2' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '6c7f6035bd0489f94e5814ae33ec4ac01d4e10b2f3eb9cf1947aa7a7062aa5a2'
          when /musl/i
            '6a7e1db2c4a491a0ce5aec7c3b7562704620c0031045b1ac5f0dc1ec29a27987'
          when /linux|arch/i
            'f9d1d94111b24b361073ea164b5e267492eaaf7511d22c4ddedc3ce7d203d212'
          when /darwin/i
            'a8650c2a246bb797ab57b9634903658a7d34ede61f1aeb4148419554ff9163f4'
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
