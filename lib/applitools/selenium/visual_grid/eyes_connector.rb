# frozen_string_literal: true
module Applitools
  module Selenium
    class EyesConnector < ::Applitools::EyesBase
      USE_DEFAULT_MATCH_TIMEOUT = -1

      attr_accessor :browser_info, :test_result, :driver, :dummy_region_provider, :dont_get_title,
        :current_uuid, :render_statuses, :device_name, :driver_lock
      public :server_connector

      class RegionProvider
        def region
          Applitools::Region::EMPTY
        end
      end

      def initialize(*args)
        options = Applitools::Utils.extract_options!(args)
        super
        self.render_statuses = {}
        self.dummy_region_provider = RegionProvider.new
        self.dont_get_title = false
        self.driver_lock = options[:driver_lock]
      end

      def ensure_config
        self.config = Applitools::Selenium::Configuration.new
      end

      def open(driver, browser_info)
        self.driver = driver
        self.browser_info = browser_info
        self.device_name = browser_info && browser_info.emulation_info && browser_info.emulation_info.device_name
        logger.info "opening EyesConnector for #{config.short_description} with viewport size: #{browser_info}"
        config.viewport_size = browser_info.viewport_size
        open_base
        # ensure_running_session
      end

      def check(name, target, check_task_uuid)
        self.current_uuid = check_task_uuid
        target_to_check = target.finalize
        timeout = target_to_check.options[:timeout] || USE_DEFAULT_MATCH_TIMEOUT

        match_data = Applitools::Selenium::VgMatchWindowData.new
        match_data.tag = name
        match_data.render_id = render_status['renderId']
        update_default_settings(match_data)
        begin
          driver_lock.synchronize do
            match_data.read_target(target_to_check, driver, selector_regions)
          end
        rescue Applitools::Selenium::VgMatchWindowData::RegionCoordinatesError => e
          logger.error "Error retrieving coordinates for region #{e.region}"
          logger.error e.message
        end

        check_result = check_window_base(
          dummy_region_provider, timeout, match_data
        )
        self.current_uuid = nil
        check_result
      end

      def base_agent_id
        "eyes.selenium.visualgrid.ruby/#{Applitools::VERSION}"
      end

      def close(throw_exception = true, be_silent = false)
        self.current_uuid = nil
        self.test_result = super
      end

      def capture_screenshot
        nil
      end

      def render_status_for_task(uuid, status)
        render_statuses[uuid] = status
      end

      def render_status
        status = render_statuses[current_uuid]
        raise Applitools::EyesError, 'Got empty render status!' if
            status.nil? || !status.is_a?(Hash) || status.keys.empty?
        status
      end

      def screenshot_url
        render_status['imageLocation']
      end

      def dom_url
        render_status['domLocation']
      end

      def selector_regions
        render_status['selectorRegions']
      end

      # def match_level_keys
      #   %w(match_level exact scale remainder ).map(&:to_sym)
      # end

      def update_default_settings(match_data)
        config.match_level_keys.each do |k|
          match_data.send("#{k}=", default_match_settings[k])
        end
      end

      def inferred_environment
        "useragent: #{render_status['userAgent']}"
      end

      # def default_match_settings
      #   {
      #       match_level: match_level,
      #       exact: exact,
      #       scale: server_scale,
      #       remainder: server_remainder
      #   }
      # end

      # rubocop:disable Style/AccessorMethodName
      def set_viewport_size(*_args); end
      # rubocop:enable Style/AccessorMethodName

      def app_environment
        super.tap do |env|
          env.device_info = device_name
        end
      end

      def viewport_size
        status = render_statuses[render_statuses.keys.first]
        size = status['deviceSize']
        Applitools::RectangleSize.new(size['width'], size['height'])
      end

      def title
        return driver.title unless dont_get_title
      rescue StandardError => e
        logger.warn "failed (#{e.message})"
        self.dont_get_title = false
        ''
      end

      def get_app_output_with_screenshot(region_provider, _last_screenshot)
        region = region_provider.region
        a_title = title
        Applitools::AppOutputWithScreenshot.new(
          Applitools::AppOutput.new(a_title, '').tap do |o|
            o.location = region.location unless region.empty?
            o.dom_url = dom_url
            o.screenshot_url = screenshot_url if respond_to?(:screenshot_url) && !screenshot_url.nil?
          end,
          nil,
          true
        )
      end
    end
  end
end
