require 'applitools/selenium/configuration'
require 'timeout'

module Applitools
  module Selenium
    class VisualGridEyes
      DOM_EXTRACTION_TIMEOUT = 300 #seconds or 5 minutes
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
        self.test_list = Applitools::Selenium::TestList.new
        options = Applitools::Utils.extract_options!(args)
        Applitools::ArgumentGuard.hash(options, 'options', [:driver])

        config.app_name = options[:app_name] if config.app_name.nil? || config.app_name && config.app_name.empty?
        config.test_name = options[:test_name] if config.test_name.nil? || config.test_name && config.test_name.empty?
        config.viewport_size = Applitools::RectangleSize.from_any_argument(options[:viewport_size]) if config.viewport_size.nil? || config.viewport_size && config.viewport_size.empty?

        self.driver = options.delete(:driver)
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

        logger.info("getting all browsers info...")
        browsers_info_list = config.browsers_info
        logger.info("creating test descriptors for each browser info...")
        browsers_info_list.each(viewport_size) do |bi|
          test_list.push Applitools::Selenium::RunningTest.new(eyes_connector, bi, driver)
        end
        self.opened = true
        driver
      end

      def get_viewport_size(web_driver = driver)
        Applitools::ArgumentGuard.not_nil 'web_driver', web_driver
        Applitools::Utils::EyesSeleniumUtils.extract_viewport_size(driver)
      end

      def eyes_connector
        logger.info("creating VisualGridEyes server connector")
        ::Applitools::Selenium::EyesConnector.new(server_url, driver_lock: driver_lock).tap do |connector|
          connector.batch = batch
          connector.config = config.deep_clone
        end
      end

      def check(tag, target)
        script = <<-END
          #{Applitools::Selenium::Scripts::PROCESS_PAGE_AND_POLL} return __processPageAndPoll();
        END
        begin
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

          region_x_paths = get_regions_x_paths(target)
          render_task = RenderTask.new(
            "Render #{config.short_description} - #{tag}",
            script_thread_result[:result]['value'],
            visual_grid_manager,
            server_connector,
            region_x_paths,
            size_mod,
            region_to_check,
            target.options[:script_hooks],
            mod
          )
          test_list.each do |t|
            t.check(tag, target, render_task)
          end
          test_list.each { |t| t.becomes_not_rendered }
          test_list.each { |t| t.becomes_not_rendered }
          visual_grid_manager.enqueue_render_task render_task
        rescue StandardError => e
          test_list.each { |t| t.becomes_tested }
          Applitools::EyesLogger.error e.class.to_s
          Applitools::EyesLogger.error e.message
        end
      end

      def get_regions_x_paths(target)
        result = []
        collect_selenium_regions(target).each do |el, v|
          if [::Selenium::WebDriver::Element, Applitools::Selenium::Element].include?(el.class)
            xpath = driver.execute_script(Applitools::Selenium::Scripts::GET_ELEMENT_XPATH_JS, el)
            web_element_region = Applitools::Selenium::WebElementRegion.new(xpath, v)
            self.region_to_check = web_element_region if v == :target && size_mod == 'selector'
            result << web_element_region
            target.regions[el] = result.size - 1
          end
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

        case element_or_region
        when ::Selenium::WebDriver::Element, Applitools::Selenium::Element
          self.size_mod = 'selector'
        when Applitools::Region
          self.size_mod = 'region' unless element_or_region == Applitools::Region::EMPTY
        else
          self.size_mod = 'full-page'
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

      def close(throw_exception = true)
        return false if test_list.empty?
        test_list.each(&:close)

        until ((states = test_list.map(&:state_name).uniq).count == 1 && states.first == :completed) do
          sleep 0.5
        end
        self.opened = false

        test_list.select { |t| t.pending_exceptions && !t.pending_exceptions.empty? }.each do |t|
          t.pending_exceptions.each do |e|
            raise e
          end
        end

        if throw_exception
          test_list.map(&:test_result).compact.each do |r|
            raise Applitools::NewTestError.new new_test_error_message(r), r if r.new?
            raise Applitools::DiffsFoundError.new diffs_found_error_message(r), r if r.unresolved? && !r.new?
            raise Applitools::TestFailedError.new test_failed_error_message(r), r if r.failed?
          end
        end
        failed_results = test_list.map(&:test_result).compact.select { |r| !r.as_expected? }
        failed_results.empty? ? test_list.map(&:test_result).compact.first : failed_results
      end

      def abort_if_not_closed
        test_list.each(&:abort_if_not_closed)
      end

      def open?
        opened
      end

      def get_all_test_results
        test_list.map(&:test_result)
      end

      def set_viewport_size(value)
        begin
          Applitools::Utils::EyesSeleniumUtils.set_viewport_size driver, value
        rescue => e
          logger.error e.class.to_s
          logger.error e.message
          raise Applitools::TestFailedError.new "#{e.class} - #{e.message}"
        end
      end

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

      # Takes a snapshot of the application under test and matches it with the expected output.
      #
      # @param [String] tag An optional tag to be assosiated with the snapshot.
      # @param [Fixnum] match_timeout The amount of time to retry matching (seconds)
      def check_window(tag = nil, match_timeout = USE_DEFAULT_MATCH_TIMEOUT)
        target = Applitools::Selenium::Target.window.tap do |t|
          t.timeout(match_timeout)
          t.fully if force_full_page_screenshot
        end
        check(tag, target)
      end

      # Takes a snapshot of the application under test and matches a region of
      # a specific element with the expected region output.
      #
      # @param [Applitools::Selenium::Element] element Represents a region to check.
      # @param [Symbol] how a finder, such :css or :id. Selects a finder will be used to find an element
      #   See Selenium::Webdriver::Element#find_element documentation for full list of possible finders.
      # @param [String] what The value will be passed to a specified finder. If finder is :css it must be a css selector.
      # @param [Hash] options
      # @option options [String] :tag An optional tag to be associated with the snapshot.
      # @option options [Fixnum] :match_timeout The amount of time to retry matching. (Seconds)
      # @option options [Boolean] :stitch_content If set to true, will try to get full content of the element
      #   (including hidden content due overflow settings) by scrolling the element,
      #   taking and stitching partial screenshots.
      # @example Check region by element
      #   check_region(element, tag: 'Check a region by element', match_timeout: 3, stitch_content: false)
      # @example Check region by css selector
      #   check_region(:css, '.form-row .input#e_mail', tag: 'Check a region by element', match_timeout: 3,
      #   stitch_content: false)
      # @!parse def check_region(element, how=nil, what=nil, options = {}); end
      def check_region(*args)
        options = { timeout: USE_DEFAULT_MATCH_TIMEOUT, tag: nil }.merge! Applitools::Utils.extract_options!(args)
        target = Applitools::Selenium::Target.new.region(*args).timeout(options[:match_timeout])
        target.fully if options[:stitch_content]
        check(options[:tag], target)
      end

      # Validates the contents of an iframe and matches it with the expected output.
      #
      # @param [Hash] options The specific parameters of the desired screenshot.
      # @option options [Fixnum] :timeout The amount of time to retry matching. (Seconds)
      # @option options [String] :tag An optional tag to be associated with the snapshot.
      # @option options [String] :frame Frame element or frame name or frame id.
      # @option options [String] :name_or_id The name or id of the target frame (deprecated. use :frame instead).
      # @option options [String] :frame_element The frame element (deprecated. use :frame instead).
      # @return [Applitools::MatchResult] The match results.

      def check_frame(options = {})
        options = { timeout: USE_DEFAULT_MATCH_TIMEOUT, tag: nil }.merge!(options)
        frame = options[:frame] || options[:frame_element] || options[:name_or_id]
        target = Applitools::Selenium::Target.frame(frame).timeout(options[:timeout]).fully
        check(options[:tag], target)
      end

      # Validates the contents of a region in an iframe and matches it with the expected output.
      #
      # @param [Hash] options The specific parameters of the desired screenshot.
      # @option options [String] :name_or_id The name or id of the target frame (deprecated. use :frame instead).
      # @option options [String] :frame_element The frame element (deprecated. use :frame instead).
      # @option options [String] :frame Frame element or frame name or frame id.
      # @option options [String] :tag An optional tag to be associated with the snapshot.
      # @option options [Symbol] :by By which identifier to find the region (e.g :css, :id).
      # @option options [Fixnum] :timeout The amount of time to retry matching. (Seconds)
      # @option options [Boolean] :stitch_content Whether to stitch the content or not.
      # @return [Applitools::MatchResult] The match results.
      def check_region_in_frame(options = {})
        options = { timeout: USE_DEFAULT_MATCH_TIMEOUT, tag: nil, stitch_content: false }.merge!(options)
        Applitools::ArgumentGuard.not_nil options[:by], 'options[:by]'
        Applitools::ArgumentGuard.is_a? options[:by], 'options[:by]', Array

        how_what = options.delete(:by)
        frame = options[:frame] || options[:frame_element] || options[:name_or_id]

        target = Applitools::Selenium::Target.new.timeout(options[:timeout])
        target.frame(frame) if frame
        target.fully if options[:stitch_content]
        target.region(*how_what)

        check(options[:tag], target)
      end

      # Use this method to perform seamless testing with selenium through eyes driver.
      # It yields a block and passes to it an Applitools::Selenium::Driver instance, which wraps standard driver.
      # Using Selenium methods inside the 'test' block will send the messages to Selenium
      # after creating the Eyes triggers for them. Options are similar to {open}
      # @yieldparam driver [Applitools::Selenium::Driver] Gives a driver to a block, which translates calls to a native
      #   Selemium::Driver instance
      # @example
      #   eyes.test(app_name: 'my app', test_name: 'my test') do |driver|
      #      driver.get "http://www.google.com"
      #      driver.check_window("initial")
      #   end
      def test(options = {}, &_block)
        open(options)
        yield(driver)
        close
      ensure
        abort_if_not_closed
      end
    end
  end
end
