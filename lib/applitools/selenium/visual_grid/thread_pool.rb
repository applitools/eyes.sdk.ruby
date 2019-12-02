# frozen_string_literal: true
require 'thread'

module Applitools
  module Selenium
    class VGThreadPool
      extend Forwardable
      attr_accessor :concurrency
      def_delegator 'Applitools::EyesLogger', :logger

      def initialize(concurrency = 10)
        self.concurrency = concurrency
        @stopped = true
        @thread_group = ThreadGroup.new
        @semaphore = Mutex.new
        @next_task_block = nil
        @watchdog = nil
      end

      def on_next_task_needed(&block)
        @next_task_block = block if block_given?
      end

      def start
        @semaphore.synchronize { @stopped = false }
        init_or_renew_threads
        @watchdog = Thread.new do
          catch(:exit) do
            loop do
              throw :exit if stopped?
              sleep 5
              init_or_renew_threads
            end
          end
        end
      end

      def stop
        @watchdog.exit
        @semaphore.synchronize do
          @stopped = true
        end
        @thread_group.list.each(&:join)
        stopped?
      end

      def stopped?
        @semaphore.synchronize { @stopped }
      end

      private

      def next_task
        @semaphore.synchronize do
          return @next_task_block.call if @next_task_block && @next_task_block.respond_to?(:call)
        end
        nil
      end

      def init_or_renew_threads
        (concurrency - @thread_group.list.count).times do
          logger.debug 'starting new thread (task worker)'
          next_thread
        end
      end

      def next_thread
        thread = Thread.new do
          begin
            catch(:exit) do
              loop do
                throw :exit if stopped?
                task_to_run = next_task
                if task_to_run && task_to_run.respond_to?(:call)
                  logger.debug "Executing new task... #{task_to_run.name}"
                  task_to_run.call
                  logger.debug 'Done!'
                else
                  sleep 0.5
                end
              end
            end
            Applitools::EyesLogger.logger.info 'Worker is stopped'
          rescue => e
            Applitools::EyesLogger.logger.error "Failed to execute task - #{task_to_run.name}"
            Applitools::EyesLogger.logger.error e.message
            Applitools::EyesLogger.logger.error e.backtrace.join(' ')
          end
        end
        @thread_group.add thread
      end
    end
  end
end
