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
        return 'a2cd25dd6718225e392c2bf9636158fda2ca96b8f930c07c1b9cbdee80798273' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            'a2cd25dd6718225e392c2bf9636158fda2ca96b8f930c07c1b9cbdee80798273'
          when /musl/i
            '2ee111c318fc599fd671a7d68040906f2772f35febd078c2ad3637c4336b0221'
          when /linux|arch/i
            'ccea49bfc084be0db1b6ceb2f9903cdfd5de6e2fe395ddf41a7a3e28077f9998'
          when /darwin/i
            'b00b003490f135b36f99ef3f4e2b36164e63300345773553414a5df245b648ac'
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
