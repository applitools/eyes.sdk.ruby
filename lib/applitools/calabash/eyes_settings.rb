require 'singleton'
require 'securerandom'
module Applitools
  module Calabash
    class EyesSettings
      attr_accessor :eyes, :applitools_api_key, :app_name, :test_name, :viewport_size
      attr_accessor :tmp_dir, :screenshot_dir, :log_dir, :log_file
      attr_accessor :needs_setting_up

      include Singleton

      def initialize
        @tmp_dir = 'tmp'
        @screenshot_dir = 'screenshots'
        @log_dir = 'logs'
        @log_file = 'applitools.log'
        @needs_setting_up = true
      end

      def options_for_open
        result = { app_name: app_name, test_name: test_name }
        return result unless viewport_size
        result.merge!(viewport_size: viewport_size)
      end

      def screenshot_prefix
        File.join(Dir.getwd, tmp_dir, screenshot_dir, '')
      end

      def log_prefix
        File.join(Dir.getwd, log_dir)
      end

      def screenshot_names
        @names ||= Enumerator.new do |y|
          loop do
            y << { prefix: screenshot_prefix, name: "#{SecureRandom.uuid}.png" }
          end
        end
      end
    end
  end
end
