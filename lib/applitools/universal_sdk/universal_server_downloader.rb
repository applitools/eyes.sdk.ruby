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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.7.1/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '78f03ca61fef2b1d6f9d2eec465da3ba24463b93e6318925ddc7644aba76f4f4' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '78f03ca61fef2b1d6f9d2eec465da3ba24463b93e6318925ddc7644aba76f4f4'
          when /musl/i
            'b05e77ec31499382b8285fc1fd67f54372e791595ab803da8034d73486dcb5da'
          when /linux|arch/i
            '12a6d28bdb9e51c0878f3199249e6ec3d292aa5d6b7742d03587a7ffce446d86'
          when /darwin/i
            '24967756316e2d196d2c180dafbf3c3c8a0cdba99fa31488b80beb4889c586d4'
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
