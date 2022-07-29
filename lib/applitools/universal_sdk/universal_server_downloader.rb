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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.10.2/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return 'b89aee6b0a3cb1d220c788f01669c130a0f78fb467b96b2e104e7e3ec29cb42d' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            'b89aee6b0a3cb1d220c788f01669c130a0f78fb467b96b2e104e7e3ec29cb42d'
          when /musl/i
            'a40060c1c2e88edc4540ba447c0681c6af11decc4fedf8b7ea59dacabb3ec4ea'
          when /linux|arch/i
            '4afb7863512b84fb2c4b72c90453867ef00c49476aae60b7c7954cd94d8ffc2e'
          when /darwin/i
            '275c6b95b12e7228b4943a0686e979ae153e68814289df65d056d6ae97d4e40e'
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
