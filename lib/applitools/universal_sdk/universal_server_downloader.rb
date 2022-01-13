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
            'fbc1a0bc95b2e36b9c1bfeef672bde610ff78bb78bb2b0590189bcd4baa93815'
          when /linux|arch/i
            'e909497411de02ab543d79fc9c2522fc8a5d568d1376aecc274253e793a80c3d'
          when /darwin/i
            'ed5a650d8fedc4ec1ae7468874d7445f6d7b5185d224553ec2526deee35efb75'
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
