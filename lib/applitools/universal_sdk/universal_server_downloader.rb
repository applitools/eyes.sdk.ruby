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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%401.0.2/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        case RUBY_PLATFORM
          when /mswin|windows/i
            'b5e8160b94389cd496cca79b55bf5d17e99b307e9413deccf29784d681daf648'
          when /linux|arch/i
            'da34c88504571008ae3d0aee8ef97b793b4e20b0483c1c0d5be1142cc19c35ac'
          when /darwin/i
            '0aa411f97aa36ab4fedd7155ff99d40c372d481152c8faa15a5fbf8f3eb8e503'
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
