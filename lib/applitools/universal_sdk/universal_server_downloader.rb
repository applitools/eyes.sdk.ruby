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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.5.19/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return 'e8dbe7cedc39c89254ff7043c5d870fc78270b5b1cfc1bb1da0eea4d92fd1c87' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            'e8dbe7cedc39c89254ff7043c5d870fc78270b5b1cfc1bb1da0eea4d92fd1c87'
          when /linux|arch/i
            'd6ba4c94b8c3c0e812ecbf3db835bb8bbd35044450dd680b5fb3fe1a950365ed'
          when /darwin/i
            'f397345f9fd7c69b0db42fce0d34abfcb80b73e1bf5b8cad77a700f71e10c34f'
          else
            raise 'Unsupported platform'
        end
      end

      def filename
        return 'eyes-universal-win.exe' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
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
