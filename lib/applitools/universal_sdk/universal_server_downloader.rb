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
        return 'c8ec2e2e21934362841a56cd94337680a5ff650593f29baffa258de42c7434fd' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            'c8ec2e2e21934362841a56cd94337680a5ff650593f29baffa258de42c7434fd'
          when /musl/i
            '7439a9d1ba93913f8431d918b3aff6a8b0a9724c24348a03ac3ce91b06c31485'
          when /linux|arch/i
            '01bc4599a95e75022356353934b7ddb6b4b14d54c9a66444804425000440d02c'
          when /darwin/i
            'd5be7580e09ef7b8db05233095fc6f9a2e1a1e8e448575684796cf46cc6a6899'
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
