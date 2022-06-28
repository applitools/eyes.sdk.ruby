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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.9.3/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return 'b3b714f5ea5d64ba08456804bbb262cb17353b4db15e07195f2b655dc514601a' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            'b3b714f5ea5d64ba08456804bbb262cb17353b4db15e07195f2b655dc514601a'
          when /musl/i
            '6f095fec68ad823ffe03207455477a026fd641cdad897fda6bdb689d9e458205'
          when /linux|arch/i
            '9f549c6d476204946f4d9d54e5fc9d040918f7d9dd7809b7c202a12b33dd3193'
          when /darwin/i
            '11861368a16bd8b473fce5480da70cce3872af51ebbd73e8e2493799dc96805d'
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
