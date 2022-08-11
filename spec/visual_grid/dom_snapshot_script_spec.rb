# frozen_string_literal: true

require 'eyes_selenium'
require 'openssl'

RSpec.describe Applitools::Selenium::DomSnapshotScript, skip: true do
  let(:web_driver) { Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: [:headless]) }
  let(:runner) { Applitools::Selenium::VisualGridRunner.new(1) }
  let(:eyes) { Applitools::Selenium::Eyes.new(runner: runner) }
  let(:driver) { eyes.open(app_name: 'MyAppName', test_name: 'MyTestName', driver: web_driver, viewport_size: {width: 800, height: 550}) }
  let(:simple_test_page_url) { 'https://applitools.github.io/demo/TestPages/SimpleTestPage' }
  let(:cors_test_page_url) { 'https://applitools.github.io/demo/TestPages/CorsTestPage/' }
  let(:cookies_test_page_url) { 'https://applitools.github.io/demo/TestPages/CookiesTestPage/' }
  let(:picture_url) { 'https://applitools.github.io/demo/TestPages/SimpleTestPage/minions-300x188.jpg' }
  let(:frame_url) { 'https://afternoon-savannah-68940.herokuapp.com/#' }
  let(:expected_cookies) {[{
    domain: 'applitools.github.io',
    name: 'frame1',
    path: '/demo/TestPages/CookiesTestPage',
    secure: false,
    value: '1',
    expires: nil,
  }, {
    domain: 'applitools.github.io',
    name: 'index',
    path: '/demo/TestPages/CookiesTestPage',
    secure: false,
    value: '1',
    expires: nil,
  }]}
  let(:expected_frame_cookies) {[{
    name: 'frame1',
    value: '1',
    path: '/demo/TestPages/CookiesTestPage',
    domain: 'applitools.github.io',
    expires: nil,
    secure: false
  }, {
    name: 'index',
    value: '1',
    path: '/demo/TestPages/CookiesTestPage',
    domain: 'applitools.github.io',
    expires: nil,
    secure: false
  }]}
  let(:expected_frame_in_frame_cookies) {[{
    name: 'frame1',
    value: '1',
    path: '/demo/TestPages/CookiesTestPage',
    domain: 'applitools.github.io',
    expires: nil,
    secure: false
  }, {
    name: 'index',
    value: '1',
    path: '/demo/TestPages/CookiesTestPage',
    domain: 'applitools.github.io',
    expires: nil,
    secure: false
  }, {
    name: 'frame2',
    value: '1',
    path: '/demo/TestPages/CookiesTestPage/subdir',
    domain: 'applitools.github.io',
    expires: nil,
    secure: false
  }]}

  before(:all) do
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    Applitools::EyesLogger.log_handler = Logger.new(STDOUT) unless ENV['TRAVIS']
  end
  after do
    eyes.close_async
    driver.quit
  end

  it 'test_dom_snapshot_default' do
    driver.get(simple_test_page_url)
    urls_to_skip = []
    dont_fetch_resources = false
    script = Applitools::Selenium::DomSnapshotScript::DomSnapshotScript.new(driver, urls_to_skip, dont_fetch_resources)
    run_res = script.run

    expect(run_res['resourceUrls']).to eq([])
    expect(run_res['blobs'][0]['value'].length).to eq(0)
  end

  it 'test_dom_snapshot_serialize_resources' do
    driver.get(simple_test_page_url)
    urls_to_skip = []
    dont_fetch_resources = false
    serialize_resources = true
    script = Applitools::Selenium::DomSnapshotScript::DomSnapshotScript.new(driver, urls_to_skip, dont_fetch_resources, serialize_resources)
    run_res = script.run

    expect(run_res['resourceUrls']).to eq([])
    expect(run_res['blobs'][0]['value'].length).to eq(30296)
    pic = Base64.decode64(run_res['blobs'][0]['value'])
    expect(pic.length).to eq(22721)
  end

  it 'test_dom_snapshot_compressed' do
    driver.get(simple_test_page_url)
    urls_to_skip = []
    dont_fetch_resources = false
    serialize_resources = false
    compress_resources = true
    script = Applitools::Selenium::DomSnapshotScript::DomSnapshotScript.new(driver, urls_to_skip, dont_fetch_resources, serialize_resources, compress_resources)
    run_res = script.run

    expect(run_res['resourceUrls']).to eq([])
    expect(run_res['blobs'][0]['compressed']).to eq(true)
    expect(run_res['blobs'][0]['value'].length).to eq(21674)
    compressed_dict = run_res['blobs'][0]['value']
    compressed = compressed_dict.values.pack('C*')
    pic = Zlib::Inflate.inflate(compressed)
    expect(pic.length).to eq(22721)
  end

  it 'test_dom_snapshot_compressed_serialized' do
    driver.get(simple_test_page_url)
    urls_to_skip = []
    dont_fetch_resources = false
    serialize_resources = true
    compress_resources = true
    script = Applitools::Selenium::DomSnapshotScript::DomSnapshotScript.new(driver, urls_to_skip, dont_fetch_resources, serialize_resources, compress_resources)
    run_res = script.run

    expect(run_res['resourceUrls']).to eq([])
    expect(run_res['blobs'][0]['compressed']).to eq(true)
    expect(run_res['blobs'][0]['value'].length).to eq(28900)

    compressed = Base64.decode64(run_res['blobs'][0]['value'])
    pic = Zlib::Inflate.inflate(compressed)
    expect(pic.length).to eq(22721)
  end

  it 'test_dom_snapshot_compressed_serialized' do
    driver.get(simple_test_page_url)
    urls_to_skip = []
    dont_fetch_resources = true
    script = Applitools::Selenium::DomSnapshotScript::DomSnapshotScript.new(driver, urls_to_skip, dont_fetch_resources)
    run_res = script.run

    expect(run_res['blobs']).to eq([])
    expect(run_res['resourceUrls']).to eq([picture_url])
  end


  it 'test_create_dom_snapshot_with_cors_iframe' do
    driver.get(cors_test_page_url)

    dom_script = Applitools::Selenium::DomSnapshotScript.new driver
    dont_fetch_resources = false
    urls_to_skip = []
    enable_cross_origin_rendering = true
    use_cookies = false

    dom = dom_script.create_dom_snapshot(dont_fetch_resources, urls_to_skip, enable_cross_origin_rendering, use_cookies)

    expect(dom['frames'][0]['crossFrames'].length).to eq 1
    expect(dom['frames'][0]['crossFrames'][0]['index']).to eq 16
    expect(dom['frames'][0]['crossFrames'][0]).to have_key('selector')
    expect(dom['frames'][0]['frames'].length).to eq 1
    expect(dom['frames'][0]['frames'][0]['url']).to eq(frame_url)
  end

  it 'test_create_dom_snapshot_disable_cross_origin_rendering' do
    driver.get(cors_test_page_url)

    dom_script = Applitools::Selenium::DomSnapshotScript.new driver
    dont_fetch_resources = false
    urls_to_skip = []
    enable_cross_origin_rendering = false
    use_cookies = false

    dom = dom_script.create_dom_snapshot(dont_fetch_resources, urls_to_skip, enable_cross_origin_rendering, use_cookies)

    expect(dom['frames'][0]['frames'].length).to eq 0
  end

  it 'test_create_dom_snapshot_collects_cookies_when_handling_cors_frames' do
    driver.get(cookies_test_page_url)

    dom_script = Applitools::Selenium::DomSnapshotScript.new driver
    dont_fetch_resources = false
    urls_to_skip = []
    enable_cross_origin_rendering = true
    use_cookies = true

    dom = dom_script.create_dom_snapshot(dont_fetch_resources, urls_to_skip, enable_cross_origin_rendering, use_cookies)

    expect(dom['cookies']).to eq(expected_cookies)
    expect(dom['frames'][0]['cookies']).to eq(expected_frame_cookies)
    expect(dom['frames'][0]['frames'][0]['cookies']).to eq(expected_frame_in_frame_cookies)
  end

  it 'test_create_dom_snapshot_collects_cookies_when_not_handling_cors_frames' do
    driver.get(cookies_test_page_url)

    dom_script = Applitools::Selenium::DomSnapshotScript.new driver
    dont_fetch_resources = true
    urls_to_skip = []
    enable_cross_origin_rendering = false
    use_cookies = true

    dom = dom_script.create_dom_snapshot(dont_fetch_resources, urls_to_skip, enable_cross_origin_rendering, use_cookies)

    expect(dom['cookies']).to eq(expected_cookies)
    expect(dom['frames'][0]['cookies']).to eq(expected_frame_cookies)
    expect(dom['frames'][0]['frames'][0]['cookies']).to eq(expected_frame_in_frame_cookies)
  end

  it 'test_create_dom_snapshot_doesnt_collect_cookies_when_disabled' do
    driver.get(cookies_test_page_url)

    dom_script = Applitools::Selenium::DomSnapshotScript.new driver
    dont_fetch_resources = true
    urls_to_skip = []
    enable_cross_origin_rendering = true
    use_cookies = false

    dom = dom_script.create_dom_snapshot(dont_fetch_resources, urls_to_skip, enable_cross_origin_rendering, use_cookies)

    expect(dom['cookies']).to eq(nil)
    expect(dom['frames'][0]['cookies']).to eq(nil)
    expect(dom['frames'][0]['frames'][0]['cookies']).to eq(nil)
  end

end
