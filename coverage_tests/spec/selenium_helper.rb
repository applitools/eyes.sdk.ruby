# frozen_string_literal: true
require 'spec_helper'
require 'eyes_selenium'
require 'logger'


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
      conf.force_full_page_screenshot = false
      conf.hide_caret = true
    end
    eyes.match_timeout = 0 unless is_visual_grid
    puts ENV['APPLITOOLS_SHOW_LOGS']
    eyes.log_handler = Logger.new(STDOUT) if ENV.key?('APPLITOOLS_SHOW_LOGS')
    eyes
  end

  def build_driver(args = {})
    env = get_env(args)
    Selenium::WebDriver.for :remote, desired_capabilities: env[:capabilities], url: env[:url]
  end

  def eyes_config(args)
    if args.key? :stitch_mode
      stitch_mode = Applitools::STITCH_MODE[:css] if args[:stitch_mode] == 'CSS'
      stitch_mode = Applitools::STITCH_MODE[:scroll] if args[:stitch_mode] == 'Scroll'
      @eyes.stitch_mode = stitch_mode
    end
    @eyes.test_name = args[:baseline_name] if args.key? :baseline_name
    @eyes.app_name = args[:app_name] if args.key? :app_name
    if args.key? :browsers_info
      browser_info = Applitools::Selenium::BrowsersInfo.new
      args[:browsers_info].each { |browser| browser_info.add(parse_browser_info(browser)) }
      @eyes.browsers_info = browser_info
    end
    @eyes.parent_branch_name = args[:parent_branch_name] if args.key? :parent_branch_name
    @eyes.branch_name = args[:branch_name] if args.key? :branch_name
    @eyes.hide_scrollbars = args[:hide_scrollbars] if args.key? :hide_scrollbars
    @eyes.disabled = args[:is_disabled] if args.key? :is_disabled
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
    raise 'Layout_breakpoints arent implemented in the Ruby SDK (Or it is time to update the test)' if args.key? :layout_breakpoints
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
    when 'chrome' then BrowserType::CHROME
    when 'firefox' then BrowserType::FIREFOX
    when 'safari' then BrowserType::SAFARI
    when 'ie10' then BrowserType::IE_10
    when 'ie11' then BrowserType::IE_11
    end
  end
end


