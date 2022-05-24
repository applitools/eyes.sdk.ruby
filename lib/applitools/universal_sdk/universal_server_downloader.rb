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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.5.17/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '7d76887ec7ca6512147db28eb809dcd47aa0681209a1cf37e19e84612a0d021f' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '7d76887ec7ca6512147db28eb809dcd47aa0681209a1cf37e19e84612a0d021f'
          when /linux|arch/i
            '48db7823428188e4ade0a5db808a5c8be701a49683bcae644342aa3217a19c6a'
          when /darwin/i
            '21e5deee2ce2b472a74c31db9129ffb108fc744a03abb014b8b7f6169fe5470e'
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
