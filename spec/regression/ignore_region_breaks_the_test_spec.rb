# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

RSpec.describe 'Ignore region coordinates break the test' do
  let(:web_driver) { Selenium::WebDriver.for :chrome }
  let(:eyes) do
    Applitools::Selenium::Eyes.new.tap do |e|
      e.log_handler = Logger.new(STDOUT) unless ENV['TRAVIS']
    end
  end
  let(:driver) do
    eyes.open(
      app_name: 'Hello World!', test_name: 'My first Selenium Ruby test!',
      viewport_size: { width: 800, height: 600 }, driver: web_driver
    )
  end
  let(:target) do
    Applitools::Selenium::Target
      .window
      .fully
      .ignore(:class, 'random-number')
      .match_level(:strict).ignore_caret(true)
  end

  it 'should not raise error', pending: true do
    driver.get('https://applitools.com/helloworld?diff1')
    expect { eyes.check(target) }.to_not raise_error
    eyes.close_async
    driver.quit
  end
end
