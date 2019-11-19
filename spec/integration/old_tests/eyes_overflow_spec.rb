# frozen_string_literal: true

require 'eyes_selenium'
require 'eyes_rspec'
require 'spec_helper'
require_relative 'chrome_settings'

RSpec.shared_context 'Eyes settings overflow' do
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
  config.include_context('Eyes settings overflow', :type => :eyes)
  config.around :type => :eyes do |example|
    begin
      @driver = eyes.open(app_name: example.example_group.description,
                          test_name: example.full_description, driver: web_driver,
                          viewport_size: { width: 800, height: 600 })
      example.run
      eyes.close(false)
    ensure
      web_driver.close
    end
  end
end

RSpec.describe 'Overflow workaround:', type: [:feature, :eyes], overflow: true, integration: true do
  include_context 'chrome settings'
  let(:url_to_check) { 'http://applitools.github.io/demo/TestPages/FramesTestPage/' }
  let(:selenium_server_url) { ENV['SELENIUM_SERVER_URL'] }
  let(:desired_caps) do
    if selenium_server_url.casecmp('http://ondemand.saucelabs.com/wd/hub').zero?
      caps[:username] = ENV['SAUCE_USERNAME']
      caps[:accesskey] = ENV['SAUCE_ACCESS_KEY']
    end
    caps
  end
  let(:platform) { 'linux' }
  let(:web_driver) do
    begin
      Selenium::WebDriver.for(
        :remote,
        url: selenium_server_url,
        desired_capabilities: desired_caps.merge!(platform: platform)
      )
    end
  end

  before { @driver.get(url_to_check) }

  it 'data-applitools attributes are not set initially' do
    element = @driver.find_element(:css, '#overflowing-div-image')
    html = @driver.find_element(:css, 'html')
    expect(element.attribute('data-applitool-scroll')).to be nil
    expect(element.attribute('data-applitools-original-overflow')).to be nil

    expect(html.attribute('data-applitool-scroll')).to be nil
    expect(html.attribute('data-applitools-original-overflow')).to be nil
  end

  it 'sets data-applitools-scroll for element being scrolled' do
    element = @driver.find_element(:css, '#overflowing-div')
    expect(element.attribute('data-applitools-scroll')).to be nil
    target = Applitools::Selenium::Target.region(:css, '#overflowing-div').fully
    eyes.check('overflowing-div', target)
    expect(element.attribute('data-applitools-scroll')).to eq 'true'
  end

  it 'sets data-applitools-original-overflow for element being scrolled' do
    element = @driver.find_element(:css, '#overflowing-div-image')
    html = @driver.find_element(:css, 'html')
    html_overflow = html.overflow
    original_overflow = element.overflow
    expect(element.attribute('data-applitools-original-overflow')).to be nil
    expect(element.attribute('data-applitools-original-overflow')).to be nil
    expect(element.attribute('data-applitools-scroll')).to be nil
    target = Applitools::Selenium::Target.region(:css, '#overflowing-div-image').fully
    eyes.check('overflowing-div-image', target)
    expect(element.attribute('data-applitools-original-overflow')).to eq original_overflow
    expect(html.attribute('data-applitools-original-overflow')).to eq html_overflow
    expect(html.attribute('data-applitools-scroll')).to eq 'true'
  end
end
