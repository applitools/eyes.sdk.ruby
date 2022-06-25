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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.9.2/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '8231e1d013cbca58d444c37aaef4ae0c78a9642e179947965a20fcf29bd9f11f' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '8231e1d013cbca58d444c37aaef4ae0c78a9642e179947965a20fcf29bd9f11f'
          when /musl/i
            '6daa6f7f33d2347e37e7667ca0ce447d1303af6519ffcec4075900479bc314bb'
          when /linux|arch/i
            '4c60b31b076e41b132bd01f20f5ef730b81457841362029700ccd93840b4f351'
          when /darwin/i
            'ef65523821574c0189594c9046c6e6b9b07b15d52780e7ea8b1acffa46af9833'
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
