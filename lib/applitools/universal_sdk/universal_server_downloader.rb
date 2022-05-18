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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.5.11/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return 'dc8dd79855c0e7b2280afad9807be14ef03bf404c5f9610b51f10b319b92f11b' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            'dc8dd79855c0e7b2280afad9807be14ef03bf404c5f9610b51f10b319b92f11b'
          when /linux|arch/i
            '7a85935ebd3b29c198152e18a36b64abe10604f6c987dd4b2bc92e9dc5d2e2b0'
          when /darwin/i
            'b7867db41b2ed333856da9115f1ae062979e492a34ef2ea2d7ba3f705816bf48'
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
