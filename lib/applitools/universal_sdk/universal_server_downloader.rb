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
        return '7fd183305434793ea56eb221cad72e454510f0f2bc8e873ffe79ef7349f75d74' if Gem.win_platform?
        case RUBY_PLATFORM
          when /darwin/i
            'ef22cf88310823f07b5afab33ae24142d63755c6af57ed00499e991733472746'
          when /arm/i
            '45c84d46bf1ef6cc2403bad53fbd10bbecbbc80a82bcec08a72d4a7eb3e81e9b'
          when /mswin|windows|mingw/i
            '7fd183305434793ea56eb221cad72e454510f0f2bc8e873ffe79ef7349f75d74'
          when /musl/i
            '8f71533ff7fffa01e09d3837efa9a8634129ef566bc6e1012511dfdbc5cb2e50'
          when /linux|arch/i
            'f0834d22ddd74a3fac6203702f2fa42a37d69ccf058e606adc5b20b4b6c7ac6b'
          else
            raise 'Unsupported platform'
        end
      end

      def filename
        return 'eyes-universal-win.exe' if Gem.win_platform?
        case RUBY_PLATFORM
          when /darwin/i
            'eyes-universal-macos'
          when /arm/i
            'eyes-universal-linux-arm64'
          when /mswin|windows|mingw/i
            'eyes-universal-win.exe'
          when /musl/i
            'eyes-universal-alpine'
          when /linux|arch/i
            'eyes-universal-linux'
          else
            raise "Unsupported platform #{RUBY_PLATFORM}"
        end
      end

    end
  end
end
