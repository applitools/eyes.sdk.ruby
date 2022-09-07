# frozen_string_literal: true

require 'eyes_selenium'
Applitools::EyesLogger.log_handler = Logger.new(STDOUT) unless ENV['TRAVIS']

RSpec.describe "Version #{Applitools::VERSION} check on #{RUBY_PLATFORM} ruby-#{RUBY_VERSION}" do
  before(:context) do
    @runner = Applitools::ClassicRunner.new
  end
  after(:context) do
    @runner.get_all_test_results
  end

  let(:eyes) do
    eyes = Applitools::Selenium::Eyes.new(runner: @runner)
    eyes.configure {|conf| conf.save_new_tests = false }
    eyes
  end

  let(:web_driver) {
    if File.exist?('/etc/alpine-release')
      Selenium::WebDriver::Chrome::Service.driver_path = '/usr/bin/chromedriver'
    end
    Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: [:headless, 'no-sandbox'])
  }

  let(:driver) do
    eyes.open(
      app_name: "Ruby SDK v#{Applitools::VERSION}",
      test_name: "sdk-#{Applitools::VERSION} on #{RUBY_PLATFORM} ruby-#{RUBY_VERSION}",
      driver: web_driver,
      viewport_size: { width: 1280, height: 600 }
    )
  end

  after do
    web_driver.quit
    eyes.abort_if_not_closed
  end

  it 'simple test' do
    driver.get('https://applitools.com/helloworld')
    driver.find_element(:css, '.section.button-section button').click

    eyes.check('Example1', Applitools::Selenium::Target.window)
    expect { eyes.close }.to raise_error Applitools::NewTestError
  end

end
