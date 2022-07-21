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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.9.11/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '4a030c943a096974d8e22e65d6aa6dbcb3bab7e8f20a331422b5dbaec5ac0f27' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows|mingw/i
            '4a030c943a096974d8e22e65d6aa6dbcb3bab7e8f20a331422b5dbaec5ac0f27'
          when /musl/i
            'a0eceb9cfab26e98d498ae16b3d25ab43f85074f0082473e6b09f494b67acafd'
          when /linux|arch/i
            '5ff5823752632589e62c7d37fdd2de6a80a71e5247395e7ce404a46571ded572'
          when /darwin/i
            'bddfc7e7df7c147ce3ab47f874335594b8190f3f31afab2479a8e1646863a2d0'
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
