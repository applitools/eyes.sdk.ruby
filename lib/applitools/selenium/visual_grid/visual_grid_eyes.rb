# frozen_string_literal: true

require 'applitools/selenium/configuration'
require 'timeout'

module Applitools
  module Selenium
    class VisualGridEyes
      include Applitools::Selenium::Concerns::SeleniumEyes
      DOM_EXTRACTION_TIMEOUT = 300 # seconds or 5 minutes
      USE_DEFAULT_MATCH_TIMEOUT = -1
      extend Forwardable

      def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=

      attr_accessor :visual_grid_manager, :driver, :current_url, :current_config, :fetched_cache_map,
        :config, :driver_lock
      attr_accessor :test_list

      attr_accessor :api_key, :server_url, :proxy, :opened

      attr_accessor :size_mod, :region_to_check
      private :size_mod, :size_mod=, :region_to_check, :region_to_check=

      def_delegators 'config', *Applitools::Selenium::Configuration.methods_to_delegate
      def_delegators 'config', *Applitools::EyesBaseConfiguration.methods_to_delegate

      def initialize(visual_grid_manager, server_url = nil)
        ensure_config
        @server_connector = Applitools::Connectivity::ServerConnector.new(server_url)
        self.server_url = server_url if server_url
        self.visual_grid_manager = visual_grid_manager
        self.test_list = Applitools::Selenium::TestList.new
        self.opened = false
        self.test_list ||= Applitools::Selenium::TestList.new
        self.driver_lock = Mutex.new
      end

      def ensure_config
        self.config = Applitools::Selenium::Configuration.new
      end

      def configure
        return unless block_given?
        yield(config)
      end

      def open(*args)
        options = Applitools::Utils.extract_options!(args)
        Applitools::ArgumentGuard.hash(options, 'options', [:driver])

        config.app_name = options[:app_name] if config.app_name.nil? || config.app_name && config.app_name.empty?
        config.test_name = options[:test_name] if config.test_name.nil? || config.test_name && config.test_name.empty?

        if config.viewport_size.nil? || config.viewport_size && config.viewport_size.empty?
          config.viewport_size = Applitools::RectangleSize.from_any_argument(options[:viewport_size])
        end

        self.driver = Applitools::Selenium::SeleniumEyes.eyes_driver(options.delete(:driver), self)
        self.current_url = driver.current_url

        if viewport_size
          set_viewport_size(viewport_size)
        else
          self.viewport_size = get_viewport_size
        end

        visual_grid_manager.open(self)
        visual_grid_manager.add_batch(batch.id) do
          server_connector.close_batch(batch.id)
        end

        logger.info('Getting all browsers info...')
        browsers_info_list = config.browsers_info
        logger.info('Creating test descriptors for each browser info...')
        browsers_info_list.each(viewport_size) do |bi|
          test = Applitools::Selenium::RunningTest.new(eyes_connector, bi, driver).tap do |t|
            t.on_results_received do |results|
              visual_grid_manager.aggregate_result(results)
            end
          end
          test_list.push test
        end
        self.opened = true
        driver
      end

      def get_viewport_size(web_driver = driver)
        Applitools::ArgumentGuard.not_nil 'web_driver', web_driver
        Applitools::Utils::EyesSeleniumUtils.extract_viewport_size(driver)
      end

      def eyes_connector
        logger.info('Creating VisualGridEyes server connector')
        ::Applitools::Selenium::EyesConnector.new(server_url, driver_lock: driver_lock).tap do |connector|
          connector.batch = batch
          connector.config = config.deep_clone
        end
      end

      def check(tag, target)
        script = <<-END
          #{Applitools::Selenium::Scripts::PROCESS_PAGE_AND_POLL} return __processPageAndSerializePoll();
        END
        render_task = nil
        target.default_full_page_for_vg

        target_to_check = target.finalize
        begin
          check_in_frame(target_frames: target_to_check.frames) do
            sleep wait_before_screenshots
            Applitools::EyesLogger.info 'Trying to get DOM snapshot...'

            script_thread = Thread.new do
              result = {}
              while result['status'] != 'SUCCESS'
                Thread.current[:script_result] = driver.execute_script(script)
                begin
                  Thread.current[:result] = result = Oj.load(Thread.current[:script_result])
                  sleep 0.5
                rescue Oj::ParseError => e
                  Applitools::EyesLogger.warn e.message
                end
              end
            end
            sleep 0.5
            script_thread_result = script_thread.join(DOM_EXTRACTION_TIMEOUT)

            raise ::Applitools::EyesError.new 'Timeout error while getting dom snapshot!' unless script_thread_result
            Applitools::EyesLogger.info 'Done!'

            mod = Digest::SHA2.hexdigest(script_thread_result[:script_result])

            region_x_paths = get_regions_x_paths(target_to_check)
            render_task = RenderTask.new(
              "Render #{config.short_description} - #{tag}",
              script_thread_result[:result]['value'],
              visual_grid_manager,
              server_connector,
              region_x_paths,
              size_mod,
              region_to_check,
              target_to_check.options[:script_hooks],
              mod
            )
          end
          test_list.each do |t|
            t.check(tag, target_to_check, render_task)
          end
          test_list.each(&:becomes_not_rendered)
          visual_grid_manager.enqueue_render_task render_task
        rescue StandardError => e
          test_list.each(&:becomes_tested)
          Applitools::EyesLogger.error e.class.to_s
          Applitools::EyesLogger.error e.message
        end
      end

      def get_regions_x_paths(target)
        result = []
        collect_selenium_regions(target).each do |el, v|
          next unless [::Selenium::WebDriver::Element, Applitools::Selenium::Element].include?(el.class)

          xpath = driver.execute_script(Applitools::Selenium::Scripts::GET_ELEMENT_XPATH_JS, el)
          web_element_region = Applitools::Selenium::WebElementRegion.new(xpath, v)
          self.region_to_check = web_element_region.dup if v == :target && size_mod == 'selector'
          result << web_element_region
          target.regions[el] = result.size - 1
        end
        result
      end

      def collect_selenium_regions(target)
        selenium_regions = {}
        target_element = target.region_to_check
        setup_size_mode(target_element, target, :none)
        target.ignored_regions.each do |r|
          selenium_regions[element_or_region(r, target, :ignore)] = :ignore
        end
        target.floating_regions.each do |r|
          selenium_regions[element_or_region(r, target, :floating)] = :floating
        end
        target.layout_regions.each do |r|
          selenium_regions[element_or_region(r, target, :layout_regions)] = :layout
        end
        target.strict_regions.each do |r|
          selenium_regions[element_or_region(r, target, :strict_regions)] = :strict
        end
        target.content_regions.each do |r|
          selenium_regions[element_or_region(r, target, :content_regions)] = :content
        end
        target.accessibility_regions.each do |r|
          case (r = element_or_region(r, target, :accessibility_regions))
          when Array
            r.each do |rr|
              selenium_regions[rr] = :accessibility
            end
          else
            selenium_regions[r] = :accessibility
          end
        end
        selenium_regions[region_to_check] = :target if size_mod == 'selector'

        selenium_regions
      end

      def setup_size_mode(target_element, target, key)
        self.size_mod = 'full-page'

        element_or_region = element_or_region(target_element, target, key)

        self.size_mod = case element_or_region
                        when ::Selenium::WebDriver::Element, Applitools::Selenium::Element
                          'selector'
                        when Applitools::Region
                          if element_or_region == Applitools::Region::EMPTY
                            if target.options[:stitch_content]
                              'full-page'
                            else
                              element_or_region = Applitools::Region.from_location_size(
                                Applitools::Location::TOP_LEFT, viewport_size
                              )
                              'region'
                            end
                          else
                            'region'
                          end
                        else
                          'full-page'
                        end

        self.region_to_check = element_or_region
      end

      def element_or_region(target_element, target, options_key)
        if target_element.respond_to?(:call)
          region, padding_proc = target_element.call(driver, true)
          case region
          when Array
            regions_to_replace = region.map { |r| Applitools::Selenium::VGRegion.new(r, padding_proc) }
            target.replace_region(target_element, regions_to_replace, options_key)
          else
            target.replace_region(target_element, Applitools::Selenium::VGRegion.new(region, padding_proc), options_key)
          end
          region
        else
          target_element
        end
      end

      def close_async
        test_list.each(&:close)
      end

      def close(throw_exception = true)
        return false if test_list.empty?
        close_async

        until (states = test_list.map(&:state_name).uniq).count == 1 && states.first == :completed
          sleep 0.5
        end
        self.opened = false

        test_list.select { |t| t.pending_exceptions && !t.pending_exceptions.empty? }.each do |t|
          t.pending_exceptions.each do |e|
            raise e
          end
        end

        all_results = test_list.map(&:test_result).compact
        failed_results = all_results.select { |r| !r.as_expected? }

        if throw_exception
          all_results.each do |r|
            raise Applitools::NewTestError.new new_test_error_message(r), r if r.new?
            raise Applitools::DiffsFoundError.new diffs_found_error_message(r), r if r.unresolved? && !r.new?
            raise Applitools::TestFailedError.new test_failed_error_message(r), r if r.failed?
          end
        end

        failed_results.empty? ? all_results.first : failed_results
      end

      def abort_if_not_closed
        self.opened = false
        test_list.each(&:abort_if_not_closed)
      end

      def open?
        opened
      end

      # rubocop:disable Style/AccessorMethodName
      def get_all_test_results
        test_list.map(&:test_result)
      end
      # rubocop:enable Style/AccessorMethodName

      # rubocop:disable Style/AccessorMethodName
      def set_viewport_size(value)
        Applitools::Utils::EyesSeleniumUtils.set_viewport_size driver, value
      rescue => e
        logger.error e.class.to_s
        logger.error e.message
        raise Applitools::TestFailedError.new "#{e.class} - #{e.message}"
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

      def server_connector
        @server_connector.server_url = config.server_url
        @server_connector.api_key = config.api_key
        @server_connector.proxy = config.proxy if config.proxy
        @server_connector
      end

      private :new_test_error_message, :diffs_found_error_message, :test_failed_error_message

      private

      def add_mouse_trigger(_mouse_action, _element); end

      def add_text_trigger(_control, _text); end

      def ensure_frame_visible(*_args); end

      def reset_frames_scroll_position(*_args); end
    end
  end
end
