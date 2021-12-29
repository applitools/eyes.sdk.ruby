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
        open(full_url) {|cloud| File.write(where, cloud.read) }
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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%400.2.3/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        case RUBY_PLATFORM
          when /mswin|windows/i
            '5523da8bc1d05bd64a799f926644dfd8d7d2843fbd758e7b91c07e72a17062ea'
          when /linux|arch/i
            'd61735957743c3ccae7f5c9ed78361cf8f3cc7d100e8fe9ffbb574a26a5c3da7'
          when /darwin/i
            '3e35225fc924ff9c288f8255415c65460315889f0275d91ddc6e3ada0594bce8'
          else
            raise 'Unsupported platform'
        end
      end

      def filename
        case RUBY_PLATFORM
          when /mswin|windows/i
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
