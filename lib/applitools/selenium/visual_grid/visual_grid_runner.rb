# frozen_string_literal: true
module Applitools
  module Selenium
    class VisualGridRunner < ::Applitools::ClassicRunner
      # rubocop:disable Style/MutableConstant
      EMPTY_QUEUE = []
      attr_accessor :all_eyes, :resource_cache, :put_cache, :rendering_info, :render_queue
      # rubocop:enable Style/MutableConstant

      alias queue render_queue

      def initialize(concurrent_open_sessions = 10)
        super()
        self.all_eyes = []
        self.render_queue = []
        @thread_pool = Applitools::Selenium::VGThreadPool.new(concurrent_open_sessions)
        self.resource_cache = Applitools::Selenium::ResourceCache.new
        self.put_cache = Applitools::Selenium::ResourceCache.new
        init
      end

      def init
        @thread_pool.on_next_task_needed do
          (task = get_task_queue.pop).is_a?(Applitools::Selenium::VGTask) ? task : nil
        end
        @thread_pool.start
      end

      def open(eyes)
        all_eyes << eyes
      end

      def enqueue_render_task(render_task)
        render_queue.push render_task if render_task.is_a? Applitools::Selenium::RenderTask
      end

      def stop
        sleep 0.5 while all_running_tests.map(&:score).reduce(0, :+) > 0
        @thread_pool.stop
      end

      def rendering_info(connector)
        @rendering_info ||= connector.rendering_info
      end

      def get_all_test_results(throw_exception = false)
        until (states = all_running_tests.map(&:state_name).uniq).count == 1 && states.first == :completed
          sleep 0.5
        end
        failed_results = all_test_results.select { |r| !r.as_expected? }
        failed_results.each do |r|
          exception = Applitools::NewTestError.new new_test_error_message(r), r if r.new?
          exception = Applitools::DiffsFoundError.new diffs_found_error_message(r), r if r.unresolved? && !r.new?
          exception = Applitools::TestFailedError.new test_failed_error_message(r), r if r.failed?
          aggregate_exceptions(r, exception)
        end
        super
      end

      private

      def all_running_tests
        all_eyes.collect(&:test_list).flatten
      end

      def all_running_tests_by_score
        all_running_tests.sort { |x, y| y.score <=> x.score }
      end

      # rubocop:disable Style/AccessorMethodName
      def get_task_queue
        test_to_run = if render_queue.empty?
                        all_running_tests_by_score.first
                      else
                        self
                      end
        test_to_run ? test_to_run.queue : EMPTY_QUEUE
      end
      # rubocop:enable Style/AccessorMethodName

      def new_test_error_message(result)
        original_results = result.original_results
        "New test '#{original_results['name']}' " \
            "of '#{original_results['appName']}' " \
            "Please approve the baseline at #{original_results['appUrls']['session']} "
      end

      def diffs_found_error_message(result)
        original_results = result.original_results
        "Test '#{original_results['name']}' " \
            "of '#{original_results['appname']}' " \
            "detected differences! See details at #{original_results['appUrls']['session']}"
      end

      def test_failed_error_message(result)
        original_results = result.original_results
        "Test '#{original_results['name']}' of '#{original_results['appName']}' " \
            "is failed! See details at #{original_results['appUrls']['session']}"
      end
    end
  end
end
