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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.5.12/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '61c8e22d5edf256099f888bedf4745f36869c1ff018c2f4e70b44a82d7c652be' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '61c8e22d5edf256099f888bedf4745f36869c1ff018c2f4e70b44a82d7c652be'
          when /linux|arch/i
            'e324685e89f7c55a1a6a26c4516f5c59f1ac8bd8a2498983f1f8a7920f3e5110'
          when /darwin/i
            'dd425fe2e71a6d9e60bc49041a6117d13255bcae280d5ef8dba3892b4f15de4e'
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
