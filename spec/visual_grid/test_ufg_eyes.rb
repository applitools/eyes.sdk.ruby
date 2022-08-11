# frozen_string_literal: true

require 'eyes_selenium'
require 'openssl'

RSpec.describe 'ufg_cookies' do

  let(:web_driver) { Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: [:headless]) }
  let(:runner) { Applitools::Selenium::VisualGridRunner.new(1) }
  let(:eyes) { Applitools::Selenium::Eyes.new(runner: runner) }
  let(:driver) do
    eyes.open(app_name: 'Visual Grid Render Test', test_name: 'TestRenderResourceNotFound', driver: web_driver,
      viewport_size:    { width: 800, height: 550 })
  end
  let(:target_non_selector) { Applitools::Selenium::Target.window }
  let(:cookies_test_page_url) { 'https://applitools.github.io/demo/TestPages/CookiesTestPage/' }

  let(:otherdir_uri) { URI.parse('https://applitools.github.io/demo/TestPages/CookiesTestPage/otherdir/cookie.png') }
  let(:subdir_uri) { URI.parse('https://applitools.github.io/demo/TestPages/CookiesTestPage/subdir/cookie.png') }
  let(:img_logo_uri) { URI.parse('https://demo.applitools.com/img/logo-big.png') }
  let(:image1_uri) { URI.parse('https://applitools.github.io/demo/images/image_1.jpg') }

  let(:otherdir_cookies) do
    [{
      name:    'frame1',
      value:   '1',
      path:    '/demo/TestPages/CookiesTestPage',
      domain:  'applitools.github.io',
      expires: nil,
      secure:  false
    }, {
      name:    'index',
      value:   '1',
      path:    '/demo/TestPages/CookiesTestPage',
      domain:  'applitools.github.io',
      expires: nil,
      secure:  false
    }]
  end

  let(:subdir_cookies) do
    [{
      name:    'frame1',
      value:   '1',
      path:    '/demo/TestPages/CookiesTestPage',
      domain:  'applitools.github.io',
      expires: nil,
      secure:  false
    }, {
      name:    'index',
      value:   '1',
      path:    '/demo/TestPages/CookiesTestPage',
      domain:  'applitools.github.io',
      expires: nil,
      secure:  false
    }, {
      name:    'frame2',
      value:   '1',
      path:    '/demo/TestPages/CookiesTestPage/subdir',
      domain:  'applitools.github.io',
      expires: nil,
      secure:  false
    }]
  end


  before(:all) do
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    Applitools::EyesLogger.log_handler = Logger.new(STDOUT) unless ENV['TRAVIS']
  end

  after do
    driver.quit
  end


  it 'test_cookies_passed_to_download_resource_request' do
    eyes.configure do |conf|
      conf.disable_browser_fetching = true
    end
    download_resource_requests = []
    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:download_resource) do |inst, url, ua_string, cookies|
      download_resource_requests.push({ url: url, cookies: cookies })
      inst.__download_resource_without_any_instance__(url, ua_string, cookies)
    end

    driver.get(cookies_test_page_url)
    eyes.check(target_non_selector)

    eyes.close_async
    runner.get_all_test_results(false)

    expect(download_resource_requests.length).to eq(4)

    # otherdir don't have subdir cookie
    expect(download_resource_requests).to include(url: otherdir_uri, cookies: otherdir_cookies)
    # subdir has all the cookies
    expect(download_resource_requests).to include(url: subdir_uri, cookies: subdir_cookies)
    # outside resources have no cookies
    expect(download_resource_requests).to include(url: img_logo_uri, cookies: [])
    expect(download_resource_requests).to include(url: image1_uri, cookies: [])
  end



  it 'test_cookies_are_not_passed_when_disabled' do
    eyes.configure do |conf|
      conf.disable_browser_fetching = true
      conf.dont_use_cookies = true
    end
    download_resource_requests = []
    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:download_resource) do |inst, url, ua_string, cookies|
      download_resource_requests.push({ url: url, cookies: cookies })
      inst.__download_resource_without_any_instance__(url, ua_string, cookies)
    end

    driver.get(cookies_test_page_url)
    eyes.check(target_non_selector)

    eyes.close_async
    runner.get_all_test_results(false)

    expect(download_resource_requests.length).to eq(4)
    # all resources should have no cookies
    expect(download_resource_requests).to include(url: otherdir_uri, cookies: [])
    expect(download_resource_requests).to include(url: subdir_uri, cookies: [])
    expect(download_resource_requests).to include(url: img_logo_uri, cookies: [])
    expect(download_resource_requests).to include(url: image1_uri, cookies: [])
  end

end
