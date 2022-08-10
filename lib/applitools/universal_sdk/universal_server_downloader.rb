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
        return '04efe4a3ecd04e92e0d182b1db30befaf878b2f030fa697cc325560d39461d75' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '04efe4a3ecd04e92e0d182b1db30befaf878b2f030fa697cc325560d39461d75'
          when /musl/i
            '4a8e88fc4ebf8a46a4f46c17277a511d41e16a59c5d0989c8f8dc31302d71f8b'
          when /linux|arch/i
            '89589af5f3e921f6a0f0a9e27e7afb531d28fd6ccde6c5f65ab0cd8277a1b5a7'
          when /darwin/i
            '9a2dc985f2ad5bf273b6fe3cb5b3c6d4a29abfae63976f6f4e63f4112c2cdcca'
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
