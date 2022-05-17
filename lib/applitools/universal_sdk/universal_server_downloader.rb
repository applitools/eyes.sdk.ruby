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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.5.10/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '160470a4c7190d54b43fe5b8fe90ca2071198566a91cb4b453cefaa28b50d1bc' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '160470a4c7190d54b43fe5b8fe90ca2071198566a91cb4b453cefaa28b50d1bc'
          when /linux|arch/i
            'e359eefc93ac4283576a941752facd3ddd514572ab10e8c72be95bf2926dd70c'
          when /darwin/i
            '565c6596e6668cf92556a61d6797bde8c99e1d4d8df466f73572658c61f1dfdf'
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
