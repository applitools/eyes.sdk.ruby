# frozen_string_literal: true

require 'eyes_capybara'
require 'eyes_rspec'
require 'capybara/rspec'

RSpec.shared_context 'Eyes settings' do
  let(:logger) do
    Logger.new(STDOUT).tap do |l|
      l.level = Logger::FATAL
    end
  end
  let(:eyes) do
    Applitools::Selenium::Eyes.new.tap do |e|
      e.log_handler = logger
      e.stitch_mode = :css
    end
  end
end

RSpec.configure do |config|
  config.include_context('Eyes settings', :type => :eyes)
  config.around :type => :eyes do |example|
    begin
      eyes.open(app_name: example.example_group.description, test_name: example.full_description, driver: page,
                viewport_size: { width: 800, height: 600 })
      example.run
      eyes.close(true)
    ensure
      page.driver.browser.close
    end
  end
end

RSpec.shared_examples 'End to end tests for eyes_capybara' do
  let(:url_to_check) { 'http://applitools.github.io/demo/TestPages/FramesTestPage/' }

  before do
    page.visit url_to_check
  end

  let(:selenium_server_url) { ENV['SELENIUM_SERVER_URL'] }

  it 'check_window' do
    target = Applitools::Selenium::Target.window.fully
    eyes.check('check window (fully)', target)
    target = Applitools::Selenium::Target.region('overflowing-div-image').fully
    eyes.check('check region (fully)', target)
    target = Applitools::Selenium::Target.frame('frame1')
    eyes.check('check frame', target)
    target = Applitools::Selenium::Target.frame('frame1').frame('frame1-1').region(:tag_name, 'img').fully
    eyes.check('check region in frame (fully)', target)
  end
end

RSpec.describe 'Capybara sauce :chrome', type: [:feature, :eyes], capybara: true, integration: true do
  args = [].tap do |a|
    a << 'headless'
    a << 'disable-infobars'
  end

  opts =
    {
      'chromeOptions' => {
        args: args
      }
    }

  caps = Selenium::WebDriver::Remote::Capabilities.chrome.merge! opts

  if ENV['SELENIUM_SERVER_URL'] && ENV['SELENIUM_SERVER_URL'].casecmp('http://ondemand.saucelabs.com/wd/hub').zero?
    caps[:username] = ENV['SAUCE_USERNAME']
    caps[:accesskey] = ENV['SAUCE_ACCESS_KEY']
  end

  before(:context) do
    Applitools.register_capybara_driver :browser => :remote, :url => ENV['SELENIUM_SERVER_URL'],
                                        :desired_capabilities => caps
  end
  include_examples 'End to end tests for eyes_capybara'
end
