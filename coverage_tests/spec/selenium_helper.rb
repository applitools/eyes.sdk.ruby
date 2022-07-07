# frozen_string_literal: true
require 'spec_helper'
require 'eyes_selenium'
require 'logger'

LEGACY_SELENIUM = Selenium::WebDriver::VERSION.start_with?('3')

RSpec.configure do |config|

  def eyes(args)
    is_visual_grid = args[:is_visual_grid].nil? ? false : args[:is_visual_grid]
    branch_name = args[:branch_name].nil? ? 'master' : args[:branch_name]
    @runner = if is_visual_grid
                Applitools::Selenium::VisualGridRunner.new(10)
              else
                Applitools::ClassicRunner.new
              end
    eyes = Applitools::Selenium::Eyes.new(runner: @runner)
    eyes.configure do |conf|
      # conf.batch = $run_batch
      conf.api_key = ENV['APPLITOOLS_API_KEY']
      conf.branch_name = branch_name
      conf.parent_branch_name = 'master'
      conf.save_new_tests = false
      conf.hide_caret = true
    end
    eyes.match_timeout = 0 unless is_visual_grid
    puts ENV['APPLITOOLS_SHOW_LOGS']
    eyes.log_handler = Logger.new(STDOUT) if ENV.key?('APPLITOOLS_SHOW_LOGS')
    eyes
  end

  def build_driver(args = {})
    unless LEGACY_SELENIUM
      skip('Firefox 48 can only be accessed in legacy Selenium') if args[:browser] === 'firefox-48'
      skip('Legacy Safari 11 driver is not functional in Selenium 4') if args[:browser] === 'safari-11'
    end
    execution_grid = args[:executionGrid] ? true : false
    args = DEFAULT.merge(args)
    env = get_env(args)
    caps = LEGACY_SELENIUM ? env[:capabilities] : Selenium::WebDriver::Remote::Capabilities.new(env[:capabilities])
    case env[:type]
    when 'chrome'
      build_chrome(caps, env[:url], execution_grid)
    when 'firefox'
      build_firefox(caps, env[:url])
    when 'sauce'
      build_sauce(caps, env[:url])
    else
      raise "Unsupported type of the capabilities used #{env[:type]}"
    end
  end

  def eyes_config(args)
    if args.key? :stitch_mode
      stitch_mode = Applitools::STITCH_MODE[:css] if args[:stitch_mode] == 'CSS'
      stitch_mode = Applitools::STITCH_MODE[:scroll] if args[:stitch_mode] == 'Scroll'
      @eyes.stitch_mode = stitch_mode
    end
    @eyes.test_name = args[:baseline_name] if args.key? :baseline_name
    @eyes.app_name = args[:app_name] if args.key? :app_name
    @eyes.wait_before_capture = args[:wait_before_capture] if args.key? :wait_before_capture
    if args.key? :browsers_info
      browser_info = Applitools::Selenium::BrowsersInfo.new
      args[:browsers_info].each { |browser| browser_info.add(parse_browser_info(browser)) }
      @eyes.browsers_info = browser_info
    end
    @eyes.parent_branch_name = args[:parent_branch_name] if args.key? :parent_branch_name
    @eyes.branch_name = args[:branch_name] if args.key? :branch_name
    @eyes.hide_scrollbars = args[:hide_scrollbars] if args.key? :hide_scrollbars
    @eyes.disabled = args[:is_disabled] if args.key? :is_disabled
    @eyes.force_full_page_screenshot = args[:force_full_page_screenshot] if args.key? :force_full_page_screenshot
    if args.key? :default_match_settings
      if args[:default_match_settings].key? 'accessibilitySettings'
        default_match_settings = Applitools::ImageMatchSettings.new
        level = args[:default_match_settings]['accessibilitySettings']['level']
        guideline = args[:default_match_settings]['accessibilitySettings']['guidelinesVersion']
        default_match_settings.accessibility_validation = Applitools::AccessibilitySettings.new(level, guideline)
        @eyes.default_match_settings = default_match_settings
      end
    end
    if args.key? :batch
      @eyes.batch = Applitools::BatchInfo.new(args[:batch])
    end
    @eyes.layout_breakpoints = args[:layout_breakpoints] if args.key? :layout_breakpoints
    # raise 'Layout_breakpoints arent implemented in the Ruby SDK (Or it is time to update the test)' if args.key? :layout_breakpoints
  end

  def parse_browser_info(instance)
    case
    when instance.key?('name')
      info = Applitools::Selenium::DesktopBrowserInfo.new.tap do |bi|
        bi.viewport_size = Applitools::RectangleSize.new(instance['width'], instance['height'])
        bi.browser_type = get_browser_type(instance['name'])
      end
    when instance.key?('iosDeviceInfo')
      info = Applitools::Selenium::IosDeviceInfo.new(device_name: instance['iosDeviceInfo']['deviceName'],
                                                     screen_orientation: instance['iosDeviceInfo']['screenOrientation'])
    when instance.key?('chromeEmulationInfo')
      info = Applitools::Selenium::ChromeEmulationInfo.new(instance['chromeEmulationInfo']['deviceName'],
                                                           instance['chromeEmulationInfo']['screenOrientation'])
    end
    info
  end

  def get_browser_type(browser)
    case browser
    when 'chrome' then
      BrowserType::CHROME
    when 'firefox' then
      BrowserType::FIREFOX
    when 'safari' then
      BrowserType::SAFARI
    when 'ie10' then
      BrowserType::IE_10
    when 'ie11' then
      BrowserType::IE_11
    end
  end

  def build_chrome(caps, url, execution_grid)
    if execution_grid
      is_eg_url = ENV.key?('EXECUTION_GRID_URL')
      raise 'No url for set for the execution grid, check environmental variable EXECUTION_GRID_URL' unless is_eg_url
      build_remote(caps, ENV['EXECUTION_GRID_URL'])
    elsif use_docker
      build_remote(caps, url)
    elsif LEGACY_SELENIUM
      Selenium::WebDriver.for :chrome, desired_capabilities: caps
    else
      Selenium::WebDriver.for :chrome, capabilities: caps
    end
  end

  def build_firefox(caps, url)
    if use_docker
      build_remote(caps, url)
    elsif LEGACY_SELENIUM
      Selenium::WebDriver.for :firefox, desired_capabilities: caps
    else
      Selenium::WebDriver.for :firefox, capabilities: caps
    end
  end

  def build_remote(caps, url)
    if LEGACY_SELENIUM
      Selenium::WebDriver.for :remote, desired_capabilities: caps, url: url
    else
      Selenium::WebDriver.for :remote, capabilities: caps, url: url
    end
  end

  alias build_sauce build_remote

  def use_docker
    ci = ENV['CI'] == 'true' unless ENV['CI'].nil?
    use_docker_selenium = ENV['USE_DOCKER_SELENIUM'] == 'true' unless ENV['USE_DOCKER_SELENIUM'].nil?
    result = if use_docker_selenium
               use_docker_selenium
             else
               !ci
             end
    result
  end

end


