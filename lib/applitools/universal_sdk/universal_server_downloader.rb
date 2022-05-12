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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.5.6/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '589d4b3d53b6716f13a08b1473061f635dcffcec6dd4ac9bad84b4350a55c47b' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows/i
            '589d4b3d53b6716f13a08b1473061f635dcffcec6dd4ac9bad84b4350a55c47b'
          when /linux|arch/i
            '6a39252c1e265528d535b4d80ff0a350fc15aadf5a580a8e2f1d4936d3cbd0c6'
          when /darwin/i
            'f8b0b49bdd71e7df3960676c5dbf185552dade05f570acf1d153123e66560e57'
          else
            raise 'Unsupported platform'
        end
      end

      def filename
        return 'eyes-universal-win.exe' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows/i
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
