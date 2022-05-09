# frozen_string_literal: true
# rubocop:disable Lint/UnreachableCode
require 'eyes_selenium'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
Applitools::EyesLogger.log_handler = Logger.new(STDOUT) unless ENV['TRAVIS']

RSpec.describe 'Abort Async' do
  before(:context) do |example|
    @runner = Applitools::Selenium::VisualGridRunner.new(5) unless example.metadata[:skip]
  end

  let(:eyes) { Applitools::Selenium::Eyes.new(runner: @runner) }
  let(:web_driver) { Selenium::WebDriver.for :chrome }
  let(:driver) do
    eyes.open(
      app_name: 'Eyes SDK Ruby',
      test_name: 'close_async',
      driver: web_driver,
      viewport_size: Applitools::RectangleSize.new(1280, 600)
    )
  end

  after do |example|
    eyes.abort_async unless example.metadata[:skip]
  end

  after(:context) do |example|
    @runner.get_all_test_results(false) unless example.metadata[:skip]
  end

  it 'simple test', skip: true do
    driver.get('https://applitools.com')
    eyes.check('proba', Applitools::Selenium::Target.window)
    raise Applitools::EyesError.new 'Error message'
    eyes.close(false)
  end
end
# rubocop:enable Lint/UnreachableCode
