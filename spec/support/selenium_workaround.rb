# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength
RSpec.shared_context 'selenium workaround' do
  before(:all) do
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

    Applitools::EyesLogger.log_handler = Logger.new(STDOUT)
    @runner = if self.class.metadata[:visual_grid]
                $vg_runner ||= Applitools::Selenium::VisualGridRunner.new(10)
              else
                $classic_runner ||= Applitools::ClassicRunner.new
              end
    @eyes = Applitools::Selenium::Eyes.new(runner: @runner)
  end

  before do |example|
    eyes.hide_scrollbars = true
    eyes.save_new_tests = false
    eyes.force_full_page_screenshot = false
    eyes.stitch_mode = Applitools::Selenium::StitchModes::CSS
    eyes.force_full_page_screenshot = true if example.metadata[:fps]
    eyes.stitch_mode = Applitools::Selenium::StitchModes::SCROLL if example.metadata[:scroll]
    eyes.branch_name = 'master'
    eyes.proxy = Applitools::Connectivity::Proxy.new('http://localhost:8000')
    driver.get(url_for_test)
  end

  around(:example) do |example|
    begin
      @expected_properties = {}
      @expected_accessibility_regions = []
      @expected_ignore_regions = []
      @expected_floating_regions = []
      @eyes_test_result = nil
      if eyes.respond_to? :configure
        eyes.configure do |c|
          c.test_name = ''
          c.app_name = ''
          c.viewport_size = Applitools::RectangleSize.new '0x0'
        end
      end
      example.run
      @eyes_test_result = eyes.close if eyes.open?
      check_expected_properties
      check_expected_accessibility_regions
      check_expected_ignore_regions
      check_expected_floating_regions
    ensure
      driver.quit
      eyes.abort_if_not_closed
    end
  end

  let(:runner) { @runner }

  let(:eyes_test_result) { @eyes_test_result }

  let(:actual_app_output) { session_results['actualAppOutput'] }

  let(:app_output_image_match_settings) { actual_app_output[0]['imageMatchSettings'] }
  let(:app_output_accessibility) { app_output_image_match_settings['accessibility'] }
  let(:app_output_ignore) { app_output_image_match_settings['ignore'] }
  let(:app_output_floating) { app_output_image_match_settings['floating'] }

  let(:session_results) do
    Oj.load(Net::HTTP.get(session_results_url))
  end

  let(:session_query_params) do
    URI.encode_www_form('AccessToken' => eyes_test_result.secret_token, 'apiKey' => eyes.api_key, 'format' => 'json')
  end

  let(:session_results_url) do
    url = URI.parse(eyes_test_result.api_session_url)
    url.query = session_query_params
    url
  end

  let(:driver) do
    eyes.open(
      app_name: app_name, test_name: test_name, viewport_size: viewport_size, driver: web_driver
    )
  end

  let(:web_driver) do
    case ENV['BROWSER']
    when 'chrome'
      Selenium::WebDriver.for :chrome, options: chrome_options
    else
      Selenium::WebDriver.for :chrome
    end
  end

  let(:eyes) { @eyes }

  let(:app_name) do |example|
    root_example_group = proc do |group|
      next group[:description] unless group[:parent_example_group] && group[:parent_example_group][:selenium]
      root_example_group.call(group[:parent_example_group])
    end
    root_example_group.call(example.metadata[:example_group])
  end
  let(:test_name) do |example|
    name_modifiers = [example.description]
    name_modifiers << test_name_modifiers
    name_modifiers.flatten.join('_')
  end

  let(:test_name_modifiers) do
    name_modifiers = []
    name_modifiers << :FPS if eyes.force_full_page_screenshot
    name_modifiers << :Scroll unless eyes.stitch_mode == Applitools::STITCH_MODE[:css]
    name_modifiers << :VG if @runner.is_a? Applitools::Selenium::VisualGridRunner
    name_modifiers
  end

  let(:viewport_size) { { width: 700, height: 460 } }
  let(:chrome_options) do
    Selenium::WebDriver::Chrome::Options.new(
      options: { args: %w(headless disable-gpu no-sandbox disable-dev-shm-usage) }
    )
  end

  let(:test_results) { @eyes_test_result }

  def expected_accessibility_regions(*args)
    return @expected_accessibility_regions += args.first if args.length == 1 && args.first.is_a?(Array)
    @expected_accessibility_regions += args
  end

  def expected_ignore_regions(*args)
    return @expected_ignore_regions += args.first if args.length == 1 && args.first.is_a?(Array)
    @expected_ignore_regions += args
  end

  def expected_floating_regions(*args)
    return @expected_floating_regions += args.first if args.length == 1 && args.first.is_a?(Array)
    @expected_floating_regions += args
  end

  def expected_property(key, value)
    @expected_properties[key] = value
  end

  def check_expected_properties
    @expected_properties.each do |k, v|
      path = k.split(/\./)
      current_hash = app_output_image_match_settings
      path.each do |prop|
        current_hash = current_hash[prop.to_s]
      end
      expect(current_hash).to eq(v)
    end
  end

  def check_expected_accessibility_regions
    received_accessibility_regions = app_output_accessibility.map do |r|
      Applitools::AccessibilityRegion.new(
        Applitools::Region.new(r['left'], r['top'], r['width'], r['height']),
        r['type']
      )
    end
    @expected_accessibility_regions.each do |ar|
      expect(received_accessibility_regions).to include(ar)
    end
  end

  def check_expected_ignore_regions
    received_ignore_regions = app_output_ignore.map do |r|
      Applitools::Region.new(r['left'], r['top'], r['width'], r['height'])
    end

    @expected_ignore_regions.each do |ir|
      expect(received_ignore_regions).to include(ir)
    end
  end

  def check_expected_floating_regions
    received_floating_regions = app_output_floating.map do |r|
      Applitools::FloatingRegion.new(
        r['left'], r['top'], r['width'], r['height'],
        r['maxLeftOffset'], r['maxUpOffset'], r['maxRightOffset'], r['maxDownOffset']
      )
    end

    @expected_floating_regions.each do |fr|
      expect(received_floating_regions).to include(fr)
    end
  end
end
# rubocop:enable Metrics/BlockLength
