# frozen_string_literal: false

module Applitools
  module Calabash
    class Eyes < Applitools::EyesBase
      attr_accessor :device_pixel_ratio, :full_page_capture_algorithm, :base_agent_id, :title,
        :debug_screenshot, :debug_screenshot_provider, :tag_for_debug
      attr_reader :context

      def initialize(server_url = Applitools::Connectivity::ServerConnector::DEFAULT_SERVER_URL)
        super
        self.base_agent_id = "eyes.calabash.ruby/#{Applitools::VERSION}".freeze
        self.debug_screenshot = false
        self.debug_screenshot_provider = Applitools::DebugScreenshotProvider.new
                                                                            .tag_access { tag_for_debug }
                                                                            .debug_flag_access { debug_screenshot }
      end

      def open(options = {})
        Applitools::ArgumentGuard.hash options, 'open(options)', [:app_name, :test_name]
        # options[:viewport_size] = Applitools::RectangleSize.from_any_argument options[:viewport_size]
        open_base options
      end

      def check(name, target)
        self.tag_for_debug = get_tag_for_debug(name)
        check_it(name, target, Applitools::MatchWindowData.new)
      end

      def inferred_environment
        return @inferred_environment unless @inferred_environment.nil?
        return unless device_pixel_ratio
        "device pixel ratio: #{device_pixel_ratio}"
      end

      def add_context(value)
        @context = value
      end

      def remove_context
        @context = nil
      end

      def capture_screenshot
        return screenshot_provider.capture_screenshot(debug_suffix: tag_for_debug) unless full_page_capture_algorithm
        full_page_capture_algorithm.get_stitched_region
      end

      def screenshot_provider
        env = Applitools::Calabash::EnvironmentDetector.current_environment
        case env
        when :android
          Applitools::Calabash::AndroidScreenshotProvider.instance.with_density(device_pixel_ratio)
                                                         .using_context(context)
                                                         .with_debug_screenshot_provider(debug_screenshot_provider)
        when :ios
          Applitools::Calabash::IosScreenshotProvider.instance.with_density(device_pixel_ratio)
                                                     .using_context(context)
                                                     .with_debug_screenshot_provider(debug_screenshot_provider)
        end
      end

      def check_it(name, target, match_window_data)
        Applitools::ArgumentGuard.not_nil(name, 'name')

        logger.info 'Full element requested' if target.options[:stitch_content]

        self.full_page_capture_algorithm = target.options[:stitch_content] &&
          get_full_page_capture_algorithm(target.region_to_check)

        region_provider = if full_page_capture_algorithm
                            entire_screenshot_region
                          else
                            get_region_provider(target)
                          end

        match_window_data.tag = name
        update_default_settings(match_window_data)
        match_window_data.read_target(target, nil)

        self.viewport_size = Applitools::Calabash::EyesSettings.instance.viewport_size if viewport_size.nil?

        if match_window_data.is_a? Applitools::MatchSingleCheckData
          return check_single_base(
            region_provider,
            target.options[:timeout] || Applitools::EyesBase::USE_DEFAULT_TIMEOUT,
            match_window_data
          )
        end

        check_window_base(
          region_provider,
          target.options[:timeout] || Applitools::EyesBase::USE_DEFAULT_TIMEOUT,
          match_window_data
        )
      end

      def get_region_provider(target)
        if (region_to_check = target.region_to_check).nil?
          entire_screenshot_region
        else
          region_for_element(region_to_check)
        end
      end

      def get_app_output_with_screenshot(*args)
        # super do |screenshot|
        #   screenshot.scale_it!
        # end
        super(*args, &:scale_it!)
      end

      def entire_screenshot_region
        Object.new.tap do |prov|
          prov.instance_eval do
            define_singleton_method :region do
              Applitools::Region::EMPTY
            end

            define_singleton_method :coordinate_type do
              nil
            end
          end
        end
      end

      def region_for_element(region_to_check)
        Object.new.tap do |prov|
          prov.instance_eval do
            define_singleton_method :region do
              case region_to_check
              when Applitools::Calabash::CalabashElement
                region_to_check.region
              when Applitools::Region
                region_to_check
              else
                raise Applitools::EyesError, "Incompatible region type: #{region_to_check.class}"
              end
              # region_to_check.respond_to?(:region) ? region_to_check.region : region_to_check
            end
            define_singleton_method :coordinate_type do
              Applitools::Calabash::EyesCalabashScreenshot::DRIVER
            end
          end
        end
      end

      def vp_size
        viewport_size
      end

      def vp_size=(value, skip_check_if_open = false)
        unless skip_check_if_open || open?
          raise Applitools::EyesNotOpenException.new 'set_viewport_size: Eyes not open!'
        end
        Applitools::ArgumentGuard.not_nil 'value', value
        @viewport_size = Applitools::RectangleSize.for value
      end

      alias get_viewport_size vp_size
      alias set_viewport_size vp_size=

      def get_full_page_capture_algorithm(element)
        logger.info "Trying to get full page capture algorithm for element #{element}..."
        environment = Applitools::Calabash::EnvironmentDetector.current_environment
        element_class = Applitools::Calabash::Utils.send("grub_#{environment}_class_name", context, element).first
        logger.info "Trying to get FullPageCaptureAlgorithm for #{element_class}..."
        algo = Applitools::Calabash::FullPageCaptureAlgorithm.get_algorithm_class(environment, element_class)
        if algo
          logger.info "Using #{algo}"
          algo = algo.new(screenshot_provider, element, debug_screenshot_provider: debug_screenshot_provider)
        else
          logger.info "FullPageCaptureAlgorithm for #{element_class} not found. Continue with :check_region instead"
        end
        algo
      end

      def get_tag_for_debug(name)
        return "#{current_app_name} #{test_name}" if name.empty?
        "#{current_app_name} #{test_name} - #{name}"
      end
    end
  end
end
