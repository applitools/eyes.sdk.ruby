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
        full_url.open {|cloud| File.write(where, cloud.read) }
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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%401.0.9/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '8eb9d98d14480ae9ec5e2ca18b9c6e1b4e3a5427cdd6dfe5cb61cf1f53562b20' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows/i
            '8eb9d98d14480ae9ec5e2ca18b9c6e1b4e3a5427cdd6dfe5cb61cf1f53562b20'
          when /linux|arch/i
            'c89d850c984ed39142974391809e645c18e8037259f9cc4f09937d73315c3c94'
          when /darwin/i
            '2bf73d118f81b33379fa5527ed8fb5508966d88299315121b44f47570923f8e8'
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
