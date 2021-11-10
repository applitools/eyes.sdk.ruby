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
        FileUtils.chmod('+x', where)
        puts "[eyes-universal] Download complete. Server placed in #{where}"
      end

      def filepath(to)
        File.expand_path(filename, to)
      end

      private

      def base_url
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%400.1.5/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        case RUBY_PLATFORM
          when /mswin|windows/i
            '4145facec859dc81511da924f0aa2cd91cfb3db36c445715f3555465b48c2d45'
          when /linux|arch/i
            '6f559b9de46c9462e82aab80b6b77ff8fa8b31009082fec14e75fab5b097c5a4'
          when /darwin/i
            'ebc85cfcaadce161f4c0db9007f8d8a4fae8dcc17b59059a37ebbcee86c32677'
          else
            raise "Unsupported platform #{RUBY_PLATFORM}"
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
