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
        return 'f31480f28e13cdc4bc4c3c41d5afb3c077da31b11cbc20311d5a6f1155218710' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            'f31480f28e13cdc4bc4c3c41d5afb3c077da31b11cbc20311d5a6f1155218710'
          when /musl/i
            '720eb087ce7494584ec1a197a51d2702ca6411abfb90306acec8b4482d355d13'
          when /linux|arch/i
            'f1c49c3cb17c247f6e7e81cb954f665904db042abda38c2c4b1add57de9df3ca'
          when /darwin/i
            'ff07816b7454b5a37ee029c40cd4a4bc71c5f33a75f7e44fd49f33c92b20d891'
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
