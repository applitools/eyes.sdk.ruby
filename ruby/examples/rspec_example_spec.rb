# frozen_string_literal: true
require 'rspec'
require 'eyes_selenium'
require 'pry'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

RSpec.describe 'Eyes example' do
  before(:all) do
    # @runner = Applitools::Selenium::VisualGridRunner.new(12)
    # @eyes = Applitools::Selenium::Eyes.new(visual_grid_runner: @runner)
    @eyes = Applitools::Selenium::Eyes.new

    @eyes.api_key = ENV['APPLITOOLS_API_KEY']
    @eyes.log_handler = Logger.new(STDOUT)
    @eyes.match_level = Applitools::MatchLevel::LAYOUT
    @eyes.server_url = 'https://testeyes.applitools.com'
    @eyes.batch = Applitools::BatchInfo.new('Eyes RSpec example')
    @eyes.set_proxy 'http://localhost:8000'
  end

  after do
    begin
      eyes.close(true)
    ensure
      driver.close
    end
  end

  let(:web_driver) { Selenium::WebDriver.for :chrome }
  let(:eyes) { @eyes }
  let(:driver) do
    eyes.open(
      app_name: 'Eyes RSpec example',
      test_name: example_description,
      driver: web_driver,
      viewport_size: { width: 800, height: 600 }
    )
  end
  let(:example_description, &:description)

  context 'Applitools site' do
    it 'Full page' do
      driver.get('http://applitools.com')
      eyes.check('Step1', Applitools::Selenium::Target.window.fully)
    end
    it 'Logo' do
      driver.get('http://applitools.com')
      eyes.check('Applitools Logo', Applitools::Selenium::Target.region(:css, 'a.logo'))
    end
  end

  context 'Applitools example' do
    it 'Without a bug' do
      driver.get('https://applitools.com/helloworld?diff2')
      eyes.check('Example1', Applitools::Selenium::Target.window.fully)
    end
    it 'With a bug' do
      driver.get('https://applitools.com/helloworld?diff2')
      driver.find_element(:css, '.section.button-section button').click
      eyes.check('Example2', Applitools::Selenium::Target.window.fully)
    end
  end
end
