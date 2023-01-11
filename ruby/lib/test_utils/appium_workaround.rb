require_relative 'obtain_actual_app_output'

RSpec.shared_context 'Appium workaround' do
  include Applitools::TestUtils::ObtainActualAppOutput

  let(:appium_opts) { {server_url: "http://#{ENV['BROWSERSTACK_USERNAME']}:#{ENV['BROWSERSTACK_ACCESS_KEY']}@hub.browserstack.com:80/wd/hub"} }
  let(:driver) { Appium::Driver.new({ caps: caps, appium_lib: appium_opts }, false) }

  before(:all) do
    Applitools::EyesLogger.log_handler = Logger.new(STDOUT) unless ENV['TRAVIS']
    $classic_runner ||= Applitools::ClassicRunner.new
  end

  let(:eyes) { Applitools::Appium::Eyes.new(runner: runner) }
  let(:runner) { $classic_runner }

  let(:app_name) do |example|
    root_example_group = proc do |group|
      next group[:description] unless group[:parent_example_group] && group[:parent_example_group][:appium]
      root_example_group.call(group[:parent_example_group])
    end
    root_example_group.call(example.metadata[:example_group])
  end

  let(:test_name) do |example|
    name_modifiers = [example.description]
    # It might be we'll need test name modifiers in the future
    name_modifiers.flatten.join('_')
  end

  let(:test_results) { @eyes_test_result }


  before do |_example|
    driver.start_driver
    eyes.open(app_name: app_name, test_name: test_name, driver: driver)
  end

  around do |example|
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
      driver.driver_quit
    end
  end
end

RSpec.configure do |config|
  config.include_context 'Appium workaround', appium: true
end
