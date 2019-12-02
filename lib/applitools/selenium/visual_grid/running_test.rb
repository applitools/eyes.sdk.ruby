# frozen_string_literal: true
require 'state_machine'
require 'digest'
require 'applitools/selenium/visual_grid/render_task'

module Applitools
  module Selenium
    class RunningTest
      extend Forwardable
      def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=
      def_delegators 'eyes', :abort_if_not_closed
      attr_accessor  :on_results
      # rubocop:disable Metrics/BlockLength
      state_machine :initial => :new do
        state :new do
          def close
            becomes_completed
          end

          def score
            0
          end

          def queue
            Applitools::Selenium::VisualGridRunner::EMPTY_QUEUE
          end
        end

        state :not_rendered do
          def score
            render_queue.length * 10
          end

          def queue
            render_queue
          end
        end

        state :opened do
          def score
            task_queue.length
          end

          def queue
            return Applitools::Selenium::VisualGridRunner::EMPTY_QUEUE unless task_lock.nil?
            self.task_lock = task_queue.last unless task_queue.last.nil?
            task_queue
          end
        end

        state :rendered do
          def score
            open_queue.length
          end

          def queue
            open_queue
          end
        end

        state :tested do
          def score
            close_queue.length
          end

          def queue
            close_queue
          end
        end

        state :completed do
          def score
            0
          end

          def queue
            Applitools::Selenium::VisualGridRunner::EMPTY_QUEUE
          end

          def close; end
        end

        state :new do
          def close
            self.test_result = nil
            becomes_completed
          end
        end

        state :not_rendered, :opened, :rendered, :tested do
          def close
            self.test_result = nil
            close_task = Applitools::Selenium::VGTask.new("close #{browser_info}") do
              eyes.close(false)
            end
            close_task.on_task_succeeded do |task_result|
              self.test_result = task_result
              on_results.call(task_result) if on_results.respond_to? :call
            end
            close_task.on_task_error do |e|
              pending_exceptions << e
            end
            close_task.on_task_completed do
              watch_close[close_task] = true
              becomes_completed if all_tasks_completed?(watch_close)
            end
            close_queue << close_task
            watch_close[close_task] = false
          end
        end

        event :becomes_not_rendered do
          transition :new => :not_rendered
        end

        event :becomes_opened do
          transition :rendered => :opened
        end

        event :becomes_rendered do
          transition :not_rendered => :rendered
        end

        event :becomes_tested do
          transition [:new, :not_rendered, :opened] => :tested
        end

        event :becomes_completed do
          transition [:new, :not_rendered, :rendered, :opened, :tested] => :completed
        end
      end

      attr_accessor :open_queue, :task_queue, :render_queue, :close_queue, :watch_open, :watch_task,
        :watch_render, :watch_close

      attr_accessor :eyes, :browser_info, :test_result, :pending_exceptions, :driver, :task_lock

      def initialize(eyes, browser_info, driver)
        Applitools::ArgumentGuard.is_a? eyes, 'eyes', Applitools::Selenium::EyesConnector

        self.eyes = eyes
        self.browser_info = browser_info
        self.driver = driver

        self.open_queue = []
        self.task_queue = []
        self.render_queue = []
        self.close_queue = []

        self.watch_open = {}
        self.watch_task = {}
        self.watch_render = {}
        self.watch_close = {}

        self.task_lock = nil

        self.pending_exceptions = []
        super()
        init
      end

      def on_results_received(&block)
        self.on_results = block if block_given?
      end

      def abort_if_not_closed
        eyes.abort_if_not_closed
        becomes_completed
      end

      def init
        open_task = Applitools::Selenium::VGTask.new("open #{browser_info}") { eyes.open(driver, browser_info) }

        open_task.on_task_succeeded do
          watch_open[open_task] = true
          becomes_opened if all_tasks_completed?(watch_open)
        end

        open_task.on_task_error do |e|
          pending_exceptions << e
          becomes_completed
        end

        open_queue << open_task
        watch_open[open_task] = false
      end

      def check(tag, target, render_task)
        result_index = render_task.add_running_test(self)

        check_task = VGTask.new("perform check #{tag} #{target}") do
          eyes.check(tag, target, render_task.uuid)
        end

        check_task.on_task_completed do
          watch_task[check_task] = true
          self.task_lock = nil if task_lock.uuid == check_task.uuid
          becomes_tested if all_tasks_completed?(watch_task)
        end

        task_queue.insert(0, check_task)
        watch_task[check_task] = false

        render_task.on_task_succeeded do |r|
          if r[result_index] && r[result_index]['status'] == 'rendered'
            eyes.render_status_for_task(render_task.uuid, r[result_index])
            watch_render[render_task] = true
            becomes_rendered if all_tasks_completed?(watch_render)
          else
            logger.error "Wrong render status! Render returned status #{r[result_index]['status']}"
            becomes_completed
          end
        end
        render_task.on_task_error do
          becomes_completed
        end
        watch_render[render_task] = false
      end

      def all_tasks_completed?(watch)
        return true if state_name == :completed
        uniq_values = watch.values.uniq
        uniq_values.count == 1 && uniq_values.first == true
      end
      # rubocop:enable Metrics/BlockLength
    end
  end
end
