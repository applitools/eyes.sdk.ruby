# frozen_string_literal: true
require 'securerandom'
module Applitools
  module Selenium
    class VGTask
      attr_accessor :name, :uuid
      def initialize(name, &block)
        self.name = name
        @block_to_run = block if block_given?
        @callback = []
        @error_callback = []
        @completed_callback = []
        self.uuid = SecureRandom.uuid
      end

      def on_task_succeeded(&block)
        @callback.push block if block_given?
        self
      end

      def on_task_error(&block)
        @error_callback.push block if block_given?
        self
      end

      def on_task_completed(&block)
        @completed_callback.push block if block_given?
        self
      end

      def call
        return unless @block_to_run.respond_to? :call
        begin
          res = @block_to_run.call
          @callback.each do |cb|
            cb.call(res) if cb.respond_to? :call
          end
        rescue StandardError => e
          Applitools::EyesLogger.logger.error 'Failed to execute task!'
          Applitools::EyesLogger.logger.error e.message
          Applitools::EyesLogger.logger.error e.backtrace.join('\n\t')
          @error_callback.each do |ecb|
            ecb.call(e) if ecb.respond_to? :call
          end
        ensure
          @completed_callback.each do |ccb|
            ccb.call if ccb.respond_to? :call
          end
        end
      end
    end
  end
end
