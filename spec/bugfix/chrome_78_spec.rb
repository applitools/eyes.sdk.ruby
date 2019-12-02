# frozen_string_literal: true
require 'rspec'
require 'eyes_selenium'

RSpec.describe 'Chrome 78 bug' do
  let(:eyes) do
    Applitools::Selenium::Eyes.new.tap do |e|
      e.stitch_mode = :CSS
      e.log_handler = Logger.new(STDOUT)
    end
  end
  let(:original_driver) { Selenium::WebDriver.for :chrome }
  let(:driver) do
    eyes.open(
      app_name: 'Ruby SDK',
      test_name: 'Chrome78',
      viewport_size: { width: 800, height: 600 },
      driver: original_driver
    )
  end
  before { driver.get('https://applitools.github.io/demo/TestPages/FramesTestPage/') }

  it 'full window' do
    target = Applitools::Selenium::Target.window.fully
    eyes.check('full window', target)
  end
  after do
    eyes.close
    original_driver.quit
  end
end
