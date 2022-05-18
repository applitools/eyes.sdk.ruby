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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.5.13/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '80e5263d481ea605fa7864de4aff71c46ac9d537eec889f7c1d96d4af2b3065c' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '80e5263d481ea605fa7864de4aff71c46ac9d537eec889f7c1d96d4af2b3065c'
          when /linux|arch/i
            'a1b6627c5407149815973a0992ec4f79456f07eeec9d0da21203b8e3463c632b'
          when /darwin/i
            'f176b3b4ed6874844b4c37829adc094aab0dd3a071a9ea9018fbabd5d178bec2'
          else
            raise 'Unsupported platform'
        end
      end

      def filename
        return 'eyes-universal-win.exe' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            'eyes-universal-win.exe'
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
