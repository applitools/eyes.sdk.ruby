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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.7.2/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '03bff9118fa1bf40d264cee6d6d8faae462756daebc6926bf43483e439c9c5b8' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '03bff9118fa1bf40d264cee6d6d8faae462756daebc6926bf43483e439c9c5b8'
          when /musl/i
            '9c7f4a45cfab7b426894075d3dc24b601041d18617c6411e357a0c2886d5534e'
          when /linux|arch/i
            '42b97a47c0c9fc9eb2cedd315b5574389cd3af1f477db3a2e447b4eab5013607'
          when /darwin/i
            '6496983a2bbdf436714a515a07bc5b6db57e49530e8329bf894321d8789d602f'
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
