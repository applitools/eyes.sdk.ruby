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
        return '7a1d24757fe70678a7d07b154d6b33cbe2fc1962e48a4816dce281e89391ea42' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '7a1d24757fe70678a7d07b154d6b33cbe2fc1962e48a4816dce281e89391ea42'
          when /musl/i
            'c9febe3df66c8f6ca026206bcb18012b94034b5853c597530afb20bd31e566e5'
          when /linux|arch/i
            '47f25bc36c8acfc2461b52bef05d923a0bd295b5cb0686a4d4af459249eb851c'
          when /darwin/i
            'cac7c91baf21f56339c211c043aa62ce463eec06e2349f831c964c4cdc8a38a9'
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
