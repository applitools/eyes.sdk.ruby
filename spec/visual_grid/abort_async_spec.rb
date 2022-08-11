# frozen_string_literal: true
# rubocop:disable Lint/UnreachableCode
require 'eyes_selenium'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
Applitools::EyesLogger.log_handler = Logger.new(STDOUT) unless ENV['TRAVIS']

RSpec.describe 'Abort Async' do
  before(:context) do
    @runner = Applitools::Selenium::VisualGridRunner.new(5)
  end

  let(:eyes) { Applitools::Selenium::Eyes.new(runner: @runner) }
  let(:web_driver) { Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: [:headless]) }
  let(:driver) do
    eyes.open(
      app_name: 'Eyes SDK Ruby',
      test_name: 'close_async',
      driver: web_driver,
      viewport_size: Applitools::RectangleSize.new(1280, 600)
    )
  end

  after do
    eyes.abort_async
  end

  after(:context) do
    @runner.get_all_test_results(false)
  end

  it 'simple test', pending: true do
    driver.get('https://applitools.com')
    eyes.check('proba', Applitools::Selenium::Target.window)
    raise Applitools::EyesError.new 'Error message'
    eyes.close(false)
  end
end
# rubocop:enable Lint/UnreachableCode
