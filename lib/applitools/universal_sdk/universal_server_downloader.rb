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
        full_url.open {|cloud| File.write(where, cloud.read) }
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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.5.5/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return 'c15b9a6351b6377d97a166e925519fb71104170e7e1543be6ca0bf183d38335d' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows/i
            'c15b9a6351b6377d97a166e925519fb71104170e7e1543be6ca0bf183d38335d'
          when /linux|arch/i
            '4d8002503f17823742c06c3a7bc5f6388aff2a97d1f909860142797f49e2ec69'
          when /darwin/i
            '7bca37bcda1850fc3a66883d191332439fcb4900b1801fbdf6b87a8f684f4870'
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
