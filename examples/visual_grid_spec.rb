# frozen_string_literal: true

require 'rspec'
require 'eyes_selenium'
require 'pry'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

Applitools::EyesLogger.log_handler = Logger.new(STDOUT)

RSpec.shared_examples 'Test for url' do |url|
  let(:url) { url }
  let(:web_driver) { Selenium::WebDriver.for :chrome }

  let(:config) do
    Applitools::Selenium::Configuration.new.tap do |config|
      config.app_name = 'Top 10 sites'
      config.test_name = "Top 10 sites - #{url}"
      config.viewport_size = Applitools::RectangleSize.new(1280, 600)
      config.proxy = Applitools::Connectivity::Proxy.new('http://localhost:8000')
      # config.server_url = 'https://testeyes.applitools.com'
      # config.batch = @batch
      # emu = Applitools::Selenium::ChromeEmulationInfo.galaxy_s5(Applitools::Selenium::ChromeEmulationInfo::ORIENTATIONS::PORTRAIT)

      config.add_browser(1600, 1200, BrowserTypes::CHROME)
            .add_browser(1280, 1024, BrowserTypes::CHROME)
            .add_browser(1280, 1024, BrowserTypes::EDGE)
            .add_device_emulation(Devices::BlackBerryZ30, Orientations::PORTRAIT)
            .add_device_emulation(Devices::MicrosoftLumia950)
            .add_device_emulation(Devices::NokiaLumia520, Orientations::LANDSCAPE)
    end
  end

  let(:driver) do
    eyes.config = config
    eyes.open(driver: web_driver)
  end

  let(:target1) { Applitools::Selenium::Target.window.send_dom(true) }
  # let(:target1) { Applitools::Selenium::Target.window.send_dom(true).ignore(:css, '#hlogo img').ignore_displacements }#.script_hook('document.getElementsByTagName("html")[0].appendChild(document.createTextNode("some text"));') }
  let(:target2) do
    Applitools::Selenium::Target.window.fully(true).send_dom(true).floating(:css, '#hlogo img', 15, 15, 15, 15)
  end
  let(:target3) { Applitools::Selenium::Target.region(:css, '#ulogo img').send_dom(true) }
  let(:target4) { Applitools::Selenium::Target.region(Applitools::Region.new(80, 80, 350, 100)) }

  let(:eyes) { @eyes }

  after do
    eyes.close
    puts eyes.get_all_test_results.map(&:as_expected?)
    driver.quit
    eyes.abort_if_not_closed
  end

  it url do
    driver.get(url)
    eyes.check('Step1 ' + url, target1)
    # eyes.check('Step2 ' + url, target2)
    # eyes.check('Step3 ' + url, target3)
    # eyes.check('Step4 ' + url, target4)
  end
end

RSpec.describe 'My first visual grid test' do
  before(:all) do
    @runner = Applitools::Selenium::VisualGridRunner.new(48)
    @eyes = Applitools::Selenium::Eyes.new(visual_grid_runner: @runner)
    # @batch = Applitools::BatchInfo.new('MySingleTest')
  end

  after(:all) do
    puts @runner.get_all_test_results.map(&:passed?)
    @runner.stop
  end

  %w(
    http://localhost:3000
    http://opzharp.ru
    http://opzharp.ru/invest.html
    https://applitools.com
    https://lcb.org/
    https://google.com
    https://facebook.com
    https://youtube.com
    https://amazon.com
    https://ebay.com
    https://twitter.com
    https://wikipedia.org
    https://instagram.com
    https://www.target.com/c/blankets-throws/-/N-d6wsb?lnk=ThrowsBlankets%E2%80%9C,tc
    http://applitools-vg-test.surge.sh/test.html
  )[3..3].each do |url|
    it_behaves_like 'Test for url', url
  end
end
