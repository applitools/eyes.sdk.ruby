# frozen_string_literal: true

require 'eyes_selenium'

RSpec.describe 'Render Fail' do
  let(:web_driver) { Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: [:headless]) }
  let(:runner) { Applitools::Selenium::VisualGridRunner.new(5) }
  let(:eyes) { Applitools::Selenium::Eyes.new(runner: runner) }
  before(:all) do
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    Applitools::EyesLogger.log_handler = Logger.new(STDOUT) unless ENV['TRAVIS']
  end
  it 'Failed render starts a session' do
    driver = eyes.open(
      app_name: 'Session for Render Fail',
      test_name: 'failed render',
      driver: web_driver,
      viewport_size: { width: 800, height: 600 }
    )
    driver.get('http://applitools.com')
    eyes.check('step 1', Applitools::Selenium::Target.window.before_render_screenshot_hook('fail me!'))
    eyes.close_async
    results = runner.get_all_test_results(false)
    expect(results.empty?).to be_truthy
  end
end
