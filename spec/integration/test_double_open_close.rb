# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength
require 'spec_helper'

RSpec.shared_examples 'Eyes Selenium SDK - Visual Grid TestDoubleOpenClose' do
  let(:runner) do
    if self.class.metadata[:runner] == :vg
      Applitools::Selenium::VisualGridRunner.new
    else
      Applitools::ClassicRunner.new
    end
  end

  let(:web_driver) do
    case ENV['BROWSER']
    when 'chrome'
      Selenium::WebDriver.for(:chrome, options: chrome_options)
    else
      Selenium::WebDriver.for :chrome
    end
  end

  let(:eyes) { Applitools::Selenium::Eyes.new(runner: runner) }

  let(:eyes1) { Applitools::Selenium::Eyes.new(runner: runner) }

  let(:eyes2) { Applitools::Selenium::Eyes.new(runner: runner) }

  let(:app_name) { 'Applitools Eyes Ruby SDK' }

  let(:url_for_test) { 'https://applitools.github.io/demo/TestPages/VisualGridTestPage/' }

  let(:target) { Applitools::Selenium::Target.window.fully.ignore_displacements(false) }

  let(:test_name) do |ex|
    name = ex.description
    return name unless runner.is_a? Applitools::Selenium::VisualGridRunner
    "#{name}_VG"
  end

  before { web_driver.get(url_for_test) }

  after do
    runner.get_all_test_results(false)
  end

  it 'TestDoubleOpenCheckClose' do
    eyes.open(driver: web_driver, app_name: app_name, test_name: test_name, viewport_size: { width: 1200, height: 800 })
    eyes.check('Step 1', target)
    eyes.close(false)

    eyes.open(driver: web_driver, app_name: app_name, test_name: test_name, viewport_size: { width: 1200, height: 800 })
    eyes.check('Step 2', target)
    eyes.close(false)

    web_driver.quit

    all_test_results = runner.get_all_test_results(false)

    expect(all_test_results.length).to eq 2
  end

  it 'TestDoubleOpenCheckCloseAsync' do
    eyes.open(driver: web_driver, app_name: app_name, test_name: test_name, viewport_size: { width: 1200, height: 800 })
    eyes.check('Step 1', target)
    eyes.close_async

    eyes.open(driver: web_driver, app_name: app_name, test_name: test_name, viewport_size: { width: 1200, height: 800 })
    eyes.check('Step 2', target)
    eyes.close_async

    all_test_results = runner.get_all_test_results(false)
    web_driver.quit
    expect(all_test_results.length).to eq 2
  end

  it 'TestDoubleOpenCheckCloseWithDifferentInstances' do
    eyes1.open(
      driver: web_driver,
      app_name: app_name,
      test_name: test_name,
      viewport_size: { width: 1200, height: 800 }
    )
    eyes1.check('Step 1', target)
    eyes1.close(false)

    eyes2.open(
      driver: web_driver,
      app_name: app_name,
      test_name: test_name,
      viewport_size: { width: 1200, height: 800 }
    )
    eyes2.check('Step 2', target)
    eyes2.close(false)
    web_driver.quit
    all_test_results = runner.get_all_test_results(false)
    expect(all_test_results.length).to eq 2
  end

  it 'TestDoubleOpenCheckCloseAsyncWithDifferentInstances' do
    eyes1.open(
      driver: web_driver,
      app_name: app_name,
      test_name: test_name,
      viewport_size: { width: 1200, height: 800 }
    )
    eyes1.check('Step 1', target)
    eyes1.close_async
    eyes2.open(
      driver: web_driver,
      app_name: app_name,
      test_name: test_name,
      viewport_size: { width: 1200, height: 800 }
    )
    eyes2.check('Step 2', target)
    eyes2.close_async
    web_driver.quit
    all_test_results = runner.get_all_test_results(false)
    expect(all_test_results.length).to eq 2
  end

  it 'TestDoubleCheckDontGetAllResults' do
    eyes1.open(
      driver: web_driver, app_name: app_name, test_name: test_name, viewport_size: { width: 1200, height: 800 }
    )
    eyes1.check('Step 1', target)
    eyes1.check('Step 2', target)
    eyes1.close(false)
    web_driver.quit
  end
end
# rubocop:enable Metrics/BlockLength
