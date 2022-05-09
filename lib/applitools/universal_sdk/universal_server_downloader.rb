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
        'https://github.com/applitools/eyes.sdk.javascript1/releases/download/%40applitools/eyes-universal%402.5.4/'
      end

      def full_url
        URI.join(base_url, filename)
      end

      def expected_binary_sha
        return '6d6da27173b7e1d85223835405cc42aba202c30063b34ff519468fe579022127' if Gem.win_platform?
        case RUBY_PLATFORM
          when /mswin|windows/i
            '6d6da27173b7e1d85223835405cc42aba202c30063b34ff519468fe579022127'
          when /linux|arch/i
            '936ff787516a7f3c2a770596e5fe192469c3057e11fb5143650779c519799c89'
          when /darwin/i
            '0deeb3f4a820bcdde64622eefaf2d87dd4c63d7137c08c06ecb12ea769535970'
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
