# frozen_string_literal: true
require 'logger'
SAUCE_SERVER_URL = 'https://ondemand.saucelabs.com:443/wd/hub'
SAUCE_CREDENTIALS = {
    username: ENV['SAUCE_USERNAME'],
    accessKey: ENV['SAUCE_ACCESS_KEY']
}.freeze
DEVICES = {
    'Samsung Galaxy S8' => {
        browserName: '',
        name: 'Android Demo',
        platformName: 'Android',
        platformVersion: '7.0',
        appiumVersion: '1.9.1',
        deviceName: 'Samsung Galaxy S8 FHD GoogleAPI Emulator',
        automationName: 'uiautomator2',
        idleTimeout: 60
    }.merge(SAUCE_CREDENTIALS),
    'iPhone XS Simulator' => {
        browserName: '',
        name: 'iOS Native Demo',
        deviceName: 'iPhone XS Simulator',
        platformName: 'iOS',
        platformVersion: '13.2'
    }.merge(SAUCE_CREDENTIALS)
}.freeze
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  def eyes(is_visual_grid:, is_css_stitching:, is_mobile:, branch_name:)
    is_visual_grid = false if is_visual_grid.nil?
    is_css_stitching = false if is_css_stitching.nil?
    is_mobile = false if is_mobile.nil?
    if is_mobile
      require 'eyes_appium'
    else
      require 'eyes_selenium'
    end
    branch_name = 'master' if branch_name.nil?
    runner = Applitools::Selenium::VisualGridRunner.new(10) if is_visual_grid
    eyes = is_mobile ? Applitools::Appium::Eyes.new(runner: runner) : Applitools::Selenium::Eyes.new(runner: runner)
    eyes.configure do |conf|
      conf.stitch_mode = Applitools::STITCH_MODE[:css] if is_css_stitching
      # conf.batch = $run_batch
      conf.api_key = ENV['APPLITOOLS_API_KEY']
      conf.branch_name = branch_name
      conf.parent_branch_name = 'master'
      conf.save_new_tests = false
      conf.force_full_page_screenshot = false
    end
    eyes.match_timeout = 0 unless is_visual_grid
    puts ENV['APPLITOOLS_SHOW_LOGS']
    eyes.log_handler = Logger.new(STDOUT) if ENV.key?('APPLITOOLS_SHOW_LOGS')
    eyes
  end

  def driver(env:)
    if env.nil?
      require 'eyes_selenium'
      driver = Selenium::WebDriver.for :remote, :desired_capabilities => :chrome
    else
      require 'eyes_appium'
      caps = { app: env['app'] }.merge(DEVICES[env['device']])
      driver = Appium::Driver.new({ caps: caps, appium_lib: { server_url: SAUCE_SERVER_URL } }, false)
      driver.start_driver
    end
    driver
  end

  #def my_find2(driver, element)
  #  begin
  #    return driver.find_element(:accessibility_id, element)
  #  end
  #end

  
  def my_find(driver, element)
    begin
      return driver.find_element(css: element)
      rescue Selenium::WebDriver::Error::InvalidSelectorError
        begin
          return driver.find_element(accessibility_id: element)
          rescue Selenium::WebDriver::Error::NoSuchElementError
          begin
            return driver.find_element(class: element)
            rescue Selenium::WebDriver::Error::NoSuchElementError
            begin
              return driver.find_element(id: element)
              rescue Selenium::WebDriver::Error::NoSuchElementError
              begin
                return driver.find_element(uiautomator: 'new UiSelector().textContains("'+element+'")') 
              end           
            end
          end
        end
    end
  end
end
