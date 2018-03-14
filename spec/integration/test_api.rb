# frozen_string_literal: true

$batch_info ||= Applitools::BatchInfo.new 'Ruby tests'

require_relative 'eyes_test_result'

# PLATFORMS = ['Windows 10', 'Linux', 'macOS 10.12'].freeze
PLATFORMS = ['Linux'].freeze

RSpec.shared_context 'eyes integration test' do
  let(:eyes) { @eyes }
  let(:selenium_server_url) { @selenium_server_url }
  let(:web_driver) do
    begin
      drv = Selenium::WebDriver.for(
        :remote,
        url: selenium_server_url,
        desired_capabilities: caps.merge!(platform: platform)
      )
      # if drv.capabilities.platform.to_sym != symbol_platform
      #   drv.quit
      #   raise Applitools::EyesError, "Wrong platform #{drv.capabilities.platform}, expected #{symbol_platform}"
      # end
      drv
    rescue StandardError => ex
      raise StandardError, ex.message + ' ' + caps.inspect
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
    @eyes.api_key = ENV['APPLITOOLS_API_KEY']
    @eyes.log_handler = Logger.new(STDOUT).tap do |l|
      l.level = Logger::ERROR
    end
    @eyes.stitch_mode = :css
    @selenium_server_url = ENV['SELENIUM_SERVER_URL']
    @eyes.batch = $batch_info if $batch_info
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

    it 'TestCheckFrame' do
      eyes.check_frame(name_or_id: 'frame1')
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

    it 'TestCheckFrame_Fully_Fluent' do
      eyes.check('Fluent - Full Frame', Applitools::Selenium::Target.frame('frame1').fully)
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

    it 'TestCheckRegionInFrameInFrame_Fluent' do
      target = Applitools::Selenium::Target.frame('frame1').frame('frame1-1').region(:tag_name, 'img').fully
      eyes.check('Fluent - Region in Frame in Frame', target)
    end

    it 'TestCheckFrameInFrame_Fully_Fluent2' do
      eyes.check('Fluent - Window with Ignore region 2', Applitools::Selenium::Target.window.fully)
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
      expect(res.actual_floating).to floating_array_match(
        [::Applitools::FloatingRegion.new(10, 10, 20, 20, 4, 4, 21, 31)]
      )
    end

    it 'TestCheckElementFully_Fluent' do
      element = driver.find_element(:id, 'overflowing-div-image')
      eyes.check('Fluent - Region by element - fully', Applitools::Selenium::Target.region(element).fully)
    end

    it 'TestCheckElementWithIgnoreRegionByElement_Fluent' do
      element = driver.find_element(:id, 'overflowing-div-image')
      ignore_element = driver.find_element(:id, 'overflowing-div')
      eyes.check(
        'Fluent - Region by element - fully',
        Applitools::Selenium::Target.region(element).ignore(ignore_element)
      )
    end

    it 'TestCheckElement_Fluent' do
      element = driver.find_element(:id, 'overflowing-div-image')
      eyes.check('Fluent - Region by element', Applitools::Selenium::Target.region(element))
    end
  end
end

RSpec.shared_examples 'test special cases' do
  PLATFORMS.each do |platform_name|
    include_context 'eyes integration test' do
      let(:platform) { platform_name }
    end

    it 'TestCheckRegionInAVeryBigFrame' do
      eyes.check('map', Applitools::Selenium::Target.frame('frame1').region(:tag_name, 'img'))
    end

    it 'TestCheckRegionInAVeryBigFrameAfterManualSwitchToFrame' do
      # driver.switchTo().frame("frame1");
      #
      # WebElement element = driver.findElement(By.cssSelector("img"));
      # ((JavascriptExecutor) driver).executeScript("arguments[0].scrollIntoView(true);", element);
      #
      # eyes.check("", Target.region(By.cssSelector("img")));

      driver.switch_to.frame(name_or_id: 'frame1')
      element = driver.find_element(:css, 'img')
      driver.execute_script('arguments[0].scrollIntoView(true);', element)
      eyes.check('', Applitools::Selenium::Target.region(:css, 'img'))
    end
  end
end
