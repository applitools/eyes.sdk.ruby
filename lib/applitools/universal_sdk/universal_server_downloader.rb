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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.5.7/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '59a50389a2dc2ca9b22f0ae625e273107b2f6275f1b9d70bb65127994d672599' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows/i
            '59a50389a2dc2ca9b22f0ae625e273107b2f6275f1b9d70bb65127994d672599'
          when /linux|arch/i
            'b056b26fef5084e6543df47a66cdf5c331e9c7ff538239f305ffade4af5207ab'
          when /darwin/i
            'fef31b99bfe1312281b75d8eb78f5f41e8075c0bfa4b686a3bbbe50bbf19c91f'
          else
            raise 'Unsupported platform'
        end
      end

      def filename
        return 'eyes-universal-win.exe' if Gem.win_platform?
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
