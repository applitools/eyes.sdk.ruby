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
        "https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%40#{Applitools::UNIVERSAL_VERSION}/"
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '19bbda6bc23a60e235d8c193bacb54ddb2c11353e87af9567aaa2b10922e990d' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '19bbda6bc23a60e235d8c193bacb54ddb2c11353e87af9567aaa2b10922e990d'
          when /musl/i
            '4807eb157ddec3c330c7d03932fc1a35a66ddba92d04caeca225141ac3a93e2b'
          when /linux|arch/i
            'a4e53750e93852ea3aaed485364d4c831c0df0d6409da29e86e52c7a60bd5812'
          when /darwin/i
            'f559056c7c097e628bb13dbde64997559a4fbf6c2e1e49258abb0cf391df995a'
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
