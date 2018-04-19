# frozen_string_literal: true

# rubocop:disable Style/SignalException

$batch_info ||= Applitools::BatchInfo.new "Ruby tests (#{RUBY_VERSION})"

require_relative 'eyes_test_result'

PLATFORMS = if ENV['TEST_PLATFORM'] && ENV['TEST_PLATFORM'].casecmp('linux').zero?
              ['Linux'].freeze
            elsif ENV['TEST_PLATFORM'] && ENV['TEST_PLATFORM'].casecmp('windows').zero?
              ['Windows 10'].freeze
            elsif ENV['TEST_PLATFORM'] && ENV['TEST_PLATFORM'].casecmp('macos').zero?
              ['macOS 10.13'].freeze
            else
              local_platform = Gem::Platform.local.os
              local_platform = local_platform.capitalize if local_platform.casecmp('linux').zero?
              [local_platform].freeze
            end

RSpec.shared_context 'eyes integration test' do
  let(:tested_page_url) { 'http://applitools.github.io/demo/TestPages/FramesTestPage/' }
  let(:eyes) { @eyes }
  let(:selenium_server_url) { @selenium_server_url }
  let(:desired_caps) do
    if selenium_server_url.casecmp('http://ondemand.saucelabs.com/wd/hub').zero?
      caps[:username] = ENV['SAUCE_USERNAME']
      caps[:accesskey] = ENV['SAUCE_ACCESS_KEY']
    end
    caps
  end
  let(:web_driver) do
    begin
      Selenium::WebDriver.for(
        :remote,
        url: selenium_server_url,
        desired_capabilities: desired_caps.merge!(platform: platform)
      )
    end
  end

  let(:driver) do
    eyes.open(
      driver: web_driver,
      app_name: test_suit_name,
      test_name: test_name,
      viewport_size: { width: 800, height: 600 }
    )
  end

  let(:test_name) { example_name + '_' + platform.gsub(/\s+/, '_') + (force_fullpage_screenshot ? '_FPS' : '') }

  # rubocop:disable Style/SymbolProc
  let(:example_name) { |e| e.description }
  # rubocop:enable Style/SymbolProc
  let(:symbol_platform) { platform.downcase.tr(' ', '_').to_sym }

  before(:context) do
    @eyes = Applitools::Selenium::Eyes.new
    @eyes.log_handler = Logger.new(STDOUT).tap do |l|
      l.level = Logger::FATAL
    end
    @eyes.stitch_mode = :css
    @selenium_server_url = ENV['SELENIUM_SERVER_URL']
    @eyes.batch = $batch_info if $batch_info
    @eyes.debug_screenshot = true
    # TODO: check if it real works with sauce
  end

  before do
    eyes.force_full_page_screenshot = force_fullpage_screenshot
    driver.get(tested_page_url)
  end

  after do
    begin
      eyes.close if eyes.open?
    ensure
      eyes.abort_if_not_closed
      driver.quit
    end
  end
end

RSpec.shared_context 'test classic API' do
  PLATFORMS.each do |platform_name|
    include_context 'eyes integration test' do
      let(:platform) { platform_name }
    end

    it 'TestCheckWindow' do
      eyes.check_window('Window')
    end

    it 'TestCheckRegion' do
      eyes.check_region(:id, 'overflowing-div', tag: 'Region', stitch_content: true)
    end

    it 'TestCheckFrame', pending: 'Right bottom corner is corrupted' do
      eyes.check_frame(name_or_id: 'frame1')
      fail 'Right bottom corner is corrupted'
    end

    it 'TestCheckRegionInFrame' do
      eyes.check_region_in_frame(
        name_or_id: 'frame1',
        by: [:id, 'inner-frame-div'],
        tag: 'Inner frame div',
        stitch_content: true
      )
    end

    it 'TestCheckRegion2' do
      eyes.check_region(:id, 'overflowing-div-image', tag: 'minions', stitch_content: true)
    end
  end
end

RSpec.shared_examples 'test fluent API' do
  PLATFORMS.each do |platform_name|
    include_context 'eyes integration test' do
      let(:platform) { platform_name }
    end
    it 'TestCheckWindowWithIgnoreRegion_Fluent' do
      web_driver.find_element(tag_name: 'input').send_keys('My Input')
      eyes.check(
        'Fluent - Window with Ignore region',
        Applitools::Selenium::Target.window
          .fully
          .timeout(5)
          .ignore(
            Applitools::Region.new(50, 50, 100, 100)
          )
      )
    end

    it 'TestCheckRegionWithIgnoreRegion_Fluent' do
      eyes.check(
        'Fluent - Region with Ignore region',
        Applitools::Selenium::Target.region(:id, 'overflowing-div')
          .ignore(
            Applitools::Region.new(50, 50, 100, 100)
          )
      )
    end

    it 'TestCheckFrame_Fully_Fluent', pending: 'Right bottom corner is corrupted' do
      eyes.check('Fluent - Full Frame', Applitools::Selenium::Target.frame('frame1').fully)
      fail
    end

    it 'TestCheckFrame_Fluent' do
      eyes.check('Fluent - Frame', Applitools::Selenium::Target.frame('frame1'))
    end

    it 'TestCheckFrameInFrame_Fully_Fluent' do
      target = Applitools::Selenium::Target.frame('frame1').frame('frame1-1').fully
      eyes.check('Fluent - Full Frame in Frame', target)
    end

    it 'TestCheckRegionInFrame_Fluent' do
      target = Applitools::Selenium::Target.frame('frame1').region(:id, 'inner-frame-div').fully
      eyes.check('Fluent - Region in Frame', target)
    end

    it 'TestCheckRegionInFrameInFrame_Fluent', pending: 'Differs from JavaSDK implementation' do
      target = Applitools::Selenium::Target.frame('frame1').frame('frame1-1').region(:tag_name, 'img').fully
      eyes.check('Fluent - Region in Frame in Frame', target)
      fail
    end

    it 'TestScrollbarsHiddenAndReturned_Fluent' do
      eyes.check('Fluent - Window (Before)', Applitools::Selenium::Target.window.fully)
      eyes.check(
        'Fluent - Inner frame div',
        Applitools::Selenium::Target.frame('frame1').region(id: 'inner-frame-div').fully
      )
      eyes.check('Fluent - Window (After)', Applitools::Selenium::Target.window.fully)
    end

    it 'TestCheckFrameInFrame_Fully_Fluent2' do
      eyes.check('Fluent - Window', Applitools::Selenium::Target.window.fully)
      eyes.check(
        'Fluent - Full Frame in Frame 2',
        Applitools::Selenium::Target.frame('frame1').frame('frame1-1').fully
      )
    end

    it 'TestCheckWindowWithIgnoreBySelector_Fluent' do
      target = Applitools::Selenium::Target.window.ignore(:id, 'overflowing-div')
      eyes.check('Fluent - Window with ignore region by selector', target)
    end

    it 'TestCheckWindowWithFloatingBySelector_Fluent' do
      target = Applitools::Selenium::Target.window.floating(:id, 'overflowing-div', 3, 3, 20, 30)
      eyes.check('Fluent - Window with floating region by selector', target)
    end

    it 'TestCheckWindowWithFloatingByRegion_Fluent' do
      target = Applitools::Selenium::Target.window.floating(
        ::Applitools::FloatingRegion.new(10, 10, 20, 20, 3, 3, 20, 30)
      )
      eyes.check('Fluent - Window with floating region by region', target)
      res = Applitools::EyesTestResult.new(eyes.close(true), eyes)
      # expect(res.actual_floating).to floating_array_match(
      #   [::Applitools::FloatingRegion.new(10, 10, 20, 20, 4, 4, 21, 31)]
      # )
      res
    end

    it 'TestCheckElementFully_Fluent' do
      element = driver.find_element(:id, 'overflowing-div-image')
      eyes.check('Fluent - Region by element - fully', Applitools::Selenium::Target.region(element).fully)
    end

    it 'TestCheckElementWithIgnoreRegionByElementOutsideTheViewport_Fluent' do
      element = driver.find_element(:id, 'overflowing-div-image')
      ignore_element = driver.find_element(:id, 'overflowing-div')
      eyes.check(
        'Fluent - Region by element - fully',
        Applitools::Selenium::Target.region(element).ignore(ignore_element)
      )
    end

    it 'TestCheckElementWithIgnoreRegionBySameElement_Fluent' do
      element = driver.find_element(:id, 'overflowing-div-image')
      eyes.check('Fluent - Region by element', Applitools::Selenium::Target.region(element).ignore(element))
      res = Applitools::EyesTestResult.new(eyes.close(true), eyes)
      # expect(res.actual_ignore).to ignore_array_match(
      #   [::Applitools::Region.new(0, 0, 304, 184)]
      # )
      res
    end
  end
end

RSpec.shared_examples 'test special cases' do
  PLATFORMS.each do |platform_name|
    include_context 'eyes integration test' do
      let(:platform) { platform_name }
    end

    # it 'TestCheckRegionInAVeryBigFrame' do
    #   eyes.check('map', Applitools::Selenium::Target.frame('frame1').region(:tag_name, 'img'))
    # end
    #
    # it 'TestCheckRegionInAVeryBigFrameAfterManualSwitchToFrame' do
    #   # driver.switchTo().frame("frame1");
    #   #
    #   # WebElement element = driver.findElement(By.cssSelector("img"));
    #   # ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", element);
    #   #
    #   # eyes.check("", Target.region(By.cssSelector("img")));
    #
    #   driver.switch_to.frame(name_or_id: 'frame1')
    #   element = driver.find_element(:css, 'img')
    #   driver.execute_script('arguments[0].scrollIntoView(true);', element)
    #   eyes.check('', Applitools::Selenium::Target.region(:css, 'img'))
    # end
  end
end
