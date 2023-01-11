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
        return 'f47b89a30a0216ee0df0057186737099f81947044e0d13b7af85a75a724e015c' if Gem.win_platform?
        case RUBY_PLATFORM
          when /darwin/i
            'c01045a0257f1d854a7adc5dd43c964a6e441b0f556278c785d895946f423677'
          when /arm/i
            'bd37853385220c455caa106a3540d9784b894c5d1ca63c8eefc2b514389bb474'
          when /mswin|windows|mingw/i
            'f47b89a30a0216ee0df0057186737099f81947044e0d13b7af85a75a724e015c'
          when /musl/i
            'e981cd393f71118844ceb8ddd66e7d45201551f1b71553113453e78690a3bdd6'
          when /linux|arch/i
            '1571977a28b0080d9a51a5fde5e0969a2ee6cce09793e03023c59db955136f37'
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
