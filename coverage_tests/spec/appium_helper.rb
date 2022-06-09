# frozen_string_literal: true
require 'spec_helper'
require 'eyes_appium'
require 'logger'

RSpec.configure do |config|
  def eyes(opts)
    branch_name = opts[:branch_name].nil? ? 'master' : opts[:branch_name]
    eyes = Applitools::Appium::Eyes.new
    eyes.configure do |conf|
      conf.api_key = ENV['APPLITOOLS_API_KEY']
      conf.branch_name = branch_name
      conf.parent_branch_name = 'master'
      conf.save_new_tests = false
    end
    puts ENV['APPLITOOLS_SHOW_LOGS']
    eyes.log_handler = Logger.new(STDOUT) if ENV.key?('APPLITOOLS_SHOW_LOGS')
    eyes
  end

  def build_driver(args = {})
    env = get_env(args)
    driver = Appium::Driver.new({caps: env[:capabilities], appium_lib: { server_url: env[:url] } }, false)
    driver.start_driver
    driver
  end

  def eyes_config(args)
    @eyes.test_name = args[:baseline_name] if args.key? :baseline_name
    @eyes.app_name = args[:app_name] if args.key? :app_name
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
    raise 'Layout_breakpoints arent implemented in the Ruby SDK (Or it is time to update the test)' if args.key? :layout_breakpoints
  end
end


