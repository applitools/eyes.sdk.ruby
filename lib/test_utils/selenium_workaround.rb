# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength
require_relative './actual_app_output_getter'
require_relative './obtain_actual_app_output'

RSpec.shared_context 'selenium workaround' do
  include Applitools::TestUtils::ObtainActualAppOutput
  before(:all) do
    @tests_to_skip = Applitools::TestUtils::PendingTestsList.test_list
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

    # Applitools::EyesLogger.log_handler = Logger.new(STDOUT)
    @runner = if self.class.metadata[:visual_grid]
                $vg_runner ||= Applitools::Selenium::VisualGridRunner.new(10)
              else
                $classic_runner ||= Applitools::ClassicRunner.new
              end
  end

  before do |example|
    pending('Listed in the skip list') if @tests_to_skip.include?(test_name)
    eyes.hide_scrollbars = true
    eyes.save_new_tests = false
    eyes.force_full_page_screenshot = false
    eyes.stitch_mode = Applitools::Selenium::StitchModes::CSS
    eyes.force_full_page_screenshot = true if example.metadata[:fps]
    eyes.stitch_mode = Applitools::Selenium::StitchModes::SCROLL if example.metadata[:scroll]
    eyes.branch_name = 'master'
    # eyes.proxy = Applitools::Connectivity::Proxy.new('http://localhost:8000')
    driver.get(url_for_test)
  end

  around(:example) do |example|
    begin
      @actual_app_output_check = []
      @eyes_test_result = nil
      if eyes.respond_to? :configure
        eyes.configure do |c|
          c.test_name = ''
          c.app_name = ''
          c.viewport_size = Applitools::RectangleSize.new '0x0'
        end
      end
      example.run
      if eyes.open?
        if @actual_app_output_check.empty?
          eyes.close_async
        else
          @eyes_test_result = eyes.close
          @actual_app_output_check.each do |check|
            check.perform
          end
        end
      end
    ensure
      driver.quit
    end
  end

  let(:runner) { @runner }

  # def app_output(api_key, eyes_test_result = @eyes_test_result)
  #   app_output_getter = ActualAppOutputGetter.new { actual_app_output(api_key, eyes_test_result) }
  #   @actual_app_output_check.push app_output_getter
  #   app_output_getter
  # end
  #
  # def actual_app_output(api_key, eyes_test_result = @eyes_test_result)
  #   session_results(eyes_test_result.api_session_url, eyes_test_result.secret_token, api_key)['actualAppOutput']
  # end
  #
  # def session_results(api_session_url, secret_token, api_key)
  #   Oj.load(Net::HTTP.get(session_results_url(api_session_url, secret_token, api_key)))
  # end
  #
  # def session_query_params(secret_token, api_key)
  #   URI.encode_www_form('AccessToken' => secret_token, 'apiKey' => api_key, 'format' => 'json')
  # end
  #
  # def session_results_url(api_session_url, secret_token, api_key)
  #   url = URI.parse(api_session_url)
  #   url.query = session_query_params(secret_token, api_key)
  #   url
  # end

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
      Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: [:headless])
    end
  end

  let(:eyes) { Applitools::Selenium::Eyes.new(runner: runner) }

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

  let(:test_name_modifiers) do |example|
    name_modifiers = []
    name_modifiers << :FPS if eyes.force_full_page_screenshot
    name_modifiers << :Scroll if example.metadata[:scroll]
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
end
# rubocop:enable Metrics/BlockLength

RSpec.configure do |config|
  config.include_context 'selenium workaround', selenium: true
  config.include_context 'selenium workaround', visual_grid: true

  config.after(:suite) do
    # next if defined?(ParallelTests) && !ParallelTests.last_process?
    puts $vg_runner.get_all_test_results if $vg_runner
    puts $classic_runner.get_all_test_results if $classic_runner
  end
end

