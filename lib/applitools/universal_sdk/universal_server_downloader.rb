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
        return '8b109b56d5a3eac1d37a549143af555d021a492c4c62a59a3baf2167514aff5a' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '8b109b56d5a3eac1d37a549143af555d021a492c4c62a59a3baf2167514aff5a'
          when /musl/i
            '5fe3ec28936d040fc39017c31417074f0e7328e050278a1f1337e72584177310'
          when /linux|arch/i
            '752fa9b3fd01cbceb4e51e0873e85feaa17adfb4e15dee1551d7c8176eeeaf3a'
          when /darwin/i
            'c691e4d16db280ad21289eca4e8e003bc08fc4d63810d03937387561b8219b1c'
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
