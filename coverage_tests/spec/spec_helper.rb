# frozen_string_literal: true
require_relative '../../lib/test_utils/obtain_actual_app_output'
require 'driver_build'
require 'eyes_selenium'

RSpec.configure do |config|
  include Applitools::TestUtils::ObtainActualAppOutput
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  def get_test_info(results) # Note recheck
    if results.is_a?(Array) && results.size === 1
      actual_app_output(@eyes.api_key, results.first)
    elsif results.is_a?(Applitools::TestResults)
      actual_app_output(@eyes.api_key, results)
    else
      results.map {|result| actual_app_output(@eyes.api_key, result) }
    end
  end

  def get_dom(results, dom_id)
    result = (results.is_a?(Array) && results.size === 1) ? results.first : results  # Note recheck/move ?
    url = URI.parse(result.session_results_url)
    new_query_ar = URI.decode_www_form(url.query || '') << ['apiKey', ENV['APPLITOOLS_API_KEY_READ']]
    url.path = "/api/images/dom/#{dom_id}/"
    url.query = URI.encode_www_form(new_query_ar)
    asd = Net::HTTP.get(url)
    Oj.load(asd)
  end

  def get_nodes_by_attribute(node, attr)
    result = []
    if node.key?('attributes') && node['attributes'].key?(attr)
      result.push(node)
    end
    if node.key?('childNodes')
      node['childNodes'].each { |child| result.push(get_nodes_by_attribute(child, attr)) }
    end
    result.flatten
  end

  def build_driver(args = {})
    execution_grid = args[:executionGrid] ? true : false
    args = DEFAULT.merge(args)
    env = get_env(args)
    caps = env[:capabilities]
    url = env[:url]
    if args.has_key?(:device)
      build_appium(caps, url)
    else
      case env[:type]
        when 'chrome'
          build_chrome(caps, url, execution_grid)
        when 'firefox'
          build_firefox(caps, url)
        when 'sauce'
          build_sauce(caps, url)
        else
          raise "Unsupported type of the capabilities used #{env[:type]}"
      end
    end
  end

  def build_appium(caps, url)
    driver = Appium::Driver.new({caps: caps, appium_lib: { server_url: url } }, false)
    driver.start_driver
    driver
  end

  def build_chrome(caps, url, execution_grid)
    if execution_grid
      is_eg_url = ENV.key?('EXECUTION_GRID_URL')
      raise 'No url for set for the execution grid, check environmental variable EXECUTION_GRID_URL' unless is_eg_url
      build_remote(caps, ENV['EXECUTION_GRID_URL'])
    else
      use_docker ? build_remote(caps, url) : Selenium::WebDriver.for(:chrome, desired_capabilities: caps)
    end
  end

  def build_firefox(caps, url)
    use_docker ? build_remote(caps, url) : Selenium::WebDriver.for(:firefox, desired_capabilities: caps)
  end

  def build_remote(caps, url)
    Selenium::WebDriver.for :remote, desired_capabilities: caps, url: url
  end

  alias build_sauce build_remote

  def use_docker
    (ENV['USE_DOCKER_SELENIUM'] == 'true') || (ENV['CI'] != 'true')
  end

  def eyes_config(args)
    @eyes.configure do |config|
      config.test_name = args[:baseline_name] if args[:baseline_name]
      config.stitch_mode = args[:stitch_mode] if args[:stitch_mode]
      config.hide_scrollbars = args[:hide_scrollbars] if args.key? :hide_scrollbars
      config.browsers_info = args[:browsers_info] if args[:browsers_info]
      config.default_match_settings = args[:default_match_settings] if args[:default_match_settings]
      config.app_name = args[:app_name] if args.key? :app_name
      config.parent_branch_name = args[:parent_branch_name] if args.key? :parent_branch_name
      config.disabled = args[:is_disabled] if args.key? :is_disabled
      config.batch = args[:batch] if args[:batch]
      config.branch_name = args[:branch_name] if args[:branch_name]
      config.layout_breakpoints = args[:layout_breakpoints] if args[:layout_breakpoints]
    end
  end

  # def eyes_config_a(args)
  #   @eyes.test_name = args[:baseline_name] if args.key? :baseline_name
  #   @eyes.app_name = args[:app_name] if args.key? :app_name
  #   @eyes.parent_branch_name = args[:parent_branch_name] if args.key? :parent_branch_name
  #   @eyes.branch_name = args[:branch_name] if args.key? :branch_name
  #   @eyes.hide_scrollbars = args[:hide_scrollbars] if args.key? :hide_scrollbars
  #   @eyes.disabled = args[:is_disabled] if args.key? :is_disabled
  #   if args.key? :default_match_settings
  #     if args[:default_match_settings].key? 'accessibilitySettings'
  #       default_match_settings = Applitools::ImageMatchSettings.new
  #       level = args[:default_match_settings]['accessibilitySettings']['level']
  #       guideline = args[:default_match_settings]['accessibilitySettings']['guidelinesVersion']
  #       default_match_settings.accessibility_validation = Applitools::AccessibilitySettings.new(level, guideline)
  #       @eyes.default_match_settings = default_match_settings
  #     end
  #   end
  #   raise 'Layout_breakpoints arent implemented in the Ruby SDK (Or it is time to update the test)' if args.key? :layout_breakpoints
  # end

  # def eyes_config_s(args)
  #   if args.key? :stitch_mode
  #     stitch_mode = Applitools::STITCH_MODE[:css] if args[:stitch_mode] == 'CSS'
  #     stitch_mode = Applitools::STITCH_MODE[:scroll] if args[:stitch_mode] == 'Scroll'
  #     @eyes.stitch_mode = stitch_mode
  #   end
  #   @eyes.test_name = args[:baseline_name] if args.key? :baseline_name
  #   @eyes.app_name = args[:app_name] if args.key? :app_name
  #   if args.key? :browsers_info
  #     browser_info = Applitools::Selenium::BrowsersInfo.new
  #     args[:browsers_info].each { |browser| browser_info.add(parse_browser_info(browser)) }
  #     @eyes.browsers_info = browser_info
  #   end
  #   @eyes.parent_branch_name = args[:parent_branch_name] if args.key? :parent_branch_name
  #   @eyes.branch_name = args[:branch_name] if args.key? :branch_name
  #   @eyes.hide_scrollbars = args[:hide_scrollbars] if args.key? :hide_scrollbars
  #   @eyes.disabled = args[:is_disabled] if args.key? :is_disabled
  #   if args.key? :default_match_settings
  #     if args[:default_match_settings].key? 'accessibilitySettings'
  #       default_match_settings = Applitools::ImageMatchSettings.new
  #       level = args[:default_match_settings]['accessibilitySettings']['level']
  #       guideline = args[:default_match_settings]['accessibilitySettings']['guidelinesVersion']
  #       default_match_settings.accessibility_validation = Applitools::AccessibilitySettings.new(level, guideline)
  #       @eyes.default_match_settings = default_match_settings
  #     end
  #   end
  #   if args.key? :batch
  #     @eyes.batch = Applitools::BatchInfo.new(args[:batch])
  #   end
  #   raise 'Layout_breakpoints arent implemented in the Ruby SDK (Or it is time to update the test)' if args.key? :layout_breakpoints
  # end
  #
  # def parse_browser_info(instance)
  #   case
  #     when instance.key?('name')
  #       info = Applitools::Selenium::DesktopBrowserInfo.new.tap do |bi|
  #         bi.viewport_size = Applitools::RectangleSize.new(instance['width'], instance['height'])
  #         bi.browser_type = get_browser_type(instance['name'])
  #       end
  #     when instance.key?('iosDeviceInfo')
  #       info = Applitools::Selenium::IosDeviceInfo.new(device_name: instance['iosDeviceInfo']['deviceName'],
  #         screen_orientation: instance['iosDeviceInfo']['screenOrientation'])
  #     when instance.key?('chromeEmulationInfo')
  #       info = Applitools::Selenium::ChromeEmulationInfo.new(instance['chromeEmulationInfo']['deviceName'],
  #         instance['chromeEmulationInfo']['screenOrientation'])
  #   end
  #   info
  # end
  #
  # def get_browser_type(browser)
  #   case browser
  #     when 'chrome' then BrowserType::CHROME
  #     when 'firefox' then BrowserType::FIREFOX
  #     when 'safari' then BrowserType::SAFARI
  #     when 'ie10' then BrowserType::IE_10
  #     when 'ie11' then BrowserType::IE_11
  #   end
  # end

  # def eyes(args)
  #   is_visual_grid = args[:is_visual_grid].nil? ? false : args[:is_visual_grid]
  #   branch_name = args[:branch_name].nil? ? 'master' : args[:branch_name]
  #
  #   @runner = if is_visual_grid
  #     Applitools::Selenium::VisualGridRunner.new(10)
  #   else
  #     Applitools::ClassicRunner.new
  #   end
  #   eyes = Applitools::Selenium::Eyes.new(runner: @runner)
  #   # eyes = Applitools::Appium::Eyes.new
  #
  #   eyes.configure do |conf|
  #     # conf.batch = $run_batch
  #     conf.api_key = ENV['APPLITOOLS_API_KEY']
  #     conf.branch_name = branch_name
  #     conf.parent_branch_name = 'master'
  #     conf.save_new_tests = false
  #     conf.force_full_page_screenshot = false
  #     conf.hide_caret = true # s
  #   end
  #   eyes.match_timeout = 0 unless is_visual_grid
  #   puts ENV['APPLITOOLS_SHOW_LOGS']
  #   eyes.log_handler = Logger.new(STDOUT) if ENV.key?('APPLITOOLS_SHOW_LOGS')
  #   eyes
  # end

  def eyes(args)
    @runner = Object.new
    class << @runner
      def get_all_test_results(*args)
        # no-op
      end
    end
    @eyes = ::Applitools::Selenium::Eyes.new
    @eyes.runner = @runner
    @eyes.configure do |config|
      config.api_key = ENV['APPLITOOLS_API_KEY']
      config.vg = !!args[:is_visual_grid]
      config.branch_name = args[:branch_name] || 'master'
      config.batch_info = {name: 'Ruby Coverage Tests' }
      config.parent_branch_name = 'master'
      config.save_new_tests = false
      config.force_full_page_screenshot = false
    end
    puts ENV['APPLITOOLS_SHOW_LOGS']
    @eyes.log_handler = Logger.new(STDOUT) if ENV.key?('APPLITOOLS_SHOW_LOGS')
    @eyes
  end

end
