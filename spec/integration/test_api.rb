$batch_info ||= Applitools::BatchInfo.new 'Ruby tests'
RSpec.shared_context 'eyes integration test' do
  let(:eyes) { @eyes }
  let(:selenium_server_url) { @selenium_server_url }
  let(:web_driver) { Selenium::WebDriver.for :remote, url: selenium_server_url, desired_capabilities: caps }

  let(:driver) {
    eyes.open(
      driver: web_driver,
      app_name: test_suit_name,
      test_name: test_name,
      viewport_size: { width: 800, height: 600 }
    )
  }

  let(:test_name) { example_name + (force_fullpage_screenshot ? '_FPS' : '') }

  let(:example_name) { |example| example.description }

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
    # if selenium_server_url.downcase ==  'http://ondemand.saucelabs.com/wd/hub'.downcase
    #   caps[:username] = ENV['SAUCE_USERNAME']
    #   caps[:accesskey] = ENV['SAUCE_ACCESS_KEY']
    # end
  end

  before do
    eyes.force_full_page_screenshot = force_fullpage_screenshot
    driver.get(tested_page_url)
  end

  after do
    begin
      eyes.close
    ensure
      eyes.abort_if_not_closed
      driver.quit
    end
  end
end

RSpec.shared_context 'test classic API' do
  include_context 'eyes integration test'

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

RSpec.shared_examples 'test fluent API' do
  include_context 'eyes integration test'
  it 'TestCheckWindowWithIgnoreRegion_Fluent' do
    eyes.check(
      'Fluent - Window with Ignore region',
      Applitools::Selenium::Target.window
                                  .fully
                                  .timeout(5000)
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
    eyes.check('Fluent - Window with ignore region by selector')
  end

  it 'TestCheckWindowWithFloatingBySelector_Fluent' do
    target = Applitools::Selenium::Target.window.floating(:id, 'overflowing-div', 3, 3, 20, 30)
    eyes.check('Fluent - Window with floating region by selector', target)
  end

  it 'TestCheckWindowWithFloatingByRegion_Fluent' do
#     ICheckSettings settings = Target.window()
#                                   .floating(new Region(10, 10, 20, 20), 3, 3, 20, 30);
#     eyes.check("Fluent - Window with floating region by region", settings);
# -------
#     setExpectedFloatingsRegions(new FloatingMatchSettings(10, 10, 20, 20, 3, 3, 20, 30));
#     target = Applitools::Selenium::Target.window.floating()
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
    element = driver.find(:id, 'overflowing-div-image')
    eyes.check('Fluent - Region by element', Applitools::Selenium::Target.region(element))
  end
end
