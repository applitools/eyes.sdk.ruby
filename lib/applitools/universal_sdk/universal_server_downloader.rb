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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.5.14/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '138a220b14dd46312ee404ef9bc5ff2702fb8b093930c3889e826512c0f75731' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '138a220b14dd46312ee404ef9bc5ff2702fb8b093930c3889e826512c0f75731'
          when /linux|arch/i
            '268d1c4104b1343d12621a0da61fcb202f2e94d0382ac0a9f172edb9ab1bc294'
          when /darwin/i
            '3f244f0dee511136aa42959ff83b65af27ecb6ae777c8286fdc3c4aa411db6eb'
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
