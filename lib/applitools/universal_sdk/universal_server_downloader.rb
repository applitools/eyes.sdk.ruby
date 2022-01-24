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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%401.0.6/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        case RUBY_PLATFORM
          when /mswin|windows/i
            '7f5c8c21579dcfb48ad32ee3b082877ee9c0e9432e351f0a48c264d3b71986be'
          when /linux|arch/i
            '938c94e11a292abb07cbe999325d2d84854a14c5bf9e21b1bd01344aeeeb08d4'
          when /darwin/i
            'c621df215cc285ef68c26601c28784666aefd800ce556c1bac3a7a5a3e6acebc'
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
