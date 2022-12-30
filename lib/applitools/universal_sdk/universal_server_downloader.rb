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
        return 'e3b548c6bbca494577fbf91a4443227c2ae0d8e11fd08464d5f7b23102541844' if Gem.win_platform?
        case RUBY_PLATFORM
          when /arm/i
            '22e26eb31a007b01b34601fd0cc0fb44b268e38fa820217cadba165bc29cbfa6'
          when /mswin|windows|mingw/i
            'e3b548c6bbca494577fbf91a4443227c2ae0d8e11fd08464d5f7b23102541844'
          when /musl/i
            '5a6b12d37dcfbb4ec12ecf9a9e2f08a5fac9ee1922dc1b92833f0cea9511b1bb'
          when /linux|arch/i
            '5dd299732d87008618685a0b4a2ebc3e1040e6f5674fb7c53f1914a9443a008c'
          when /darwin/i
            '4553e6e4d8502f7a45beca6785370a00ce5f66520ec963bf62b0485054bb6436'
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
