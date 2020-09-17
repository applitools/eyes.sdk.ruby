# Applitools::EyesLogger.log_handler = Logger.new(STDOUT)
RSpec.describe 'Visual Grid Options', mock_connection: true do
  class TestThreadPool < Applitools::Selenium::VGThreadPool
    def run_a_task
      task_to_run = next_task
      if task_to_run && task_to_run.respond_to?(:call)
        logger.debug "Executing new task... #{task_to_run.name}"
        task_to_run.call
        logger.debug 'Done!'
      else
        sleep 0.5
      end
    end

    def start;end

    def stop
      @semaphore.synchronize do
        @stopped = true
      end
    end
  end

  class TestVgRunner < Applitools::Selenium::VisualGridRunner
    def initialize(concurrent_open_sessions = 10)
      super()
      self.all_eyes = []
      self.render_queue = []
      @thread_pool = TestThreadPool.new(concurrent_open_sessions)
      self.resource_cache = Applitools::Selenium::ResourceCache.new
      self.put_cache = Applitools::Selenium::ResourceCache.new
      init
    end

    def get_all_test_results(throw_exception = false)
      all_tasks_completed = proc do
        all_running_tests.count == 0 ||
            (states = all_running_tests.map(&:state_name).uniq).count == 1 && states.first == :completed
      end

      @thread_pool.run_a_task until all_tasks_completed.call

      failed_results = all_test_results.select { |r| !r.as_expected? }
      failed_results.each do |r|
        exception = Applitools::NewTestError.new new_test_error_message(r), r if r.new?
        exception = Applitools::DiffsFoundError.new diffs_found_error_message(r), r if r.unresolved? && !r.new?
        exception = Applitools::TestFailedError.new test_failed_error_message(r), r if r.failed?
        aggregate_exceptions(r, exception)
      end
      super
    end
  end

  let(:runner) { @runner }

  let(:eyes) do
    Applitools::Selenium::Eyes.new(runner: runner).tap do |e|
      e.set_configuration(configuration)
    end
  end

  let(:configuration) do |example|
    Applitools::Selenium::Configuration.new.tap do |c|
      c.add_browser(800, 600, BrowserType::CHROME)
      c.visual_grid_options = {'option1' => 'value1', 'option2' => false}
      c.app_name = 'Visual Grid Options'
      c.test_name = example.full_description
    end
  end

  let(:web_driver) do
    double(Selenium::WebDriver).tap do |d|
      allow(d).to receive(:driver_for_eyes).and_return(d)
      allow(d).to receive(:execute_script).and_return(100, 100)
      allow(d).to receive(:execute_script)
                      .with(Applitools::Utils::EyesSeleniumUtils::JS_GET_CURRENT_SCROLL_POSITION)
                      .and_return(left: 0, top: 0)
      allow(d).to receive(:execute_script).with(any_args) do |*_args|
        Oj.dump('status' => 'SUCCESS', 'value' => {'blobs' => [], 'resourceUrls' => [], 'frames' => []})
      end
      allow(d).to receive(:title)
      allow(d).to receive(:user_agent).and_return(nil)
      allow(d).to receive(:frame_chain).and_return([])
      allow(d).to receive(:current_url).and_return('http://www.google.com')
    end
  end

  before(:all) do
    @runner = TestVgRunner.new(1)
  end

  before do
    allow_any_instance_of(Applitools::Selenium::VisualGridRunner).to receive(:rendering_info) do
      {'resultsUrl' => 'https://www.google.com', 'stitchingServiceUrl' => 'https://www.google.com'}
    end
    allow_any_instance_of(Applitools::Utils::EyesSeleniumUtils).to receive(:set_viewport_size)
    eyes.open(driver: web_driver)
  end

  after do
    eyes.close_async
  end

  after(:all) do
    @runner.get_all_test_results(true)
  end

  it 'Global + Fluent' do
    requests = nil
    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:render) do |*args|
      requests = args[3]
      []
    end
    eyes.check(Applitools::Selenium::Target.window().visual_grid_options('option3' => 'value3', 'option4' => 5))
    eyes.close_async
    runner.get_all_test_results(true)
    expect(requests.first.options).to eq(
      {'option1' => 'value1', 'option2' => false, 'option3' => 'value3', 'option4' => 5}
    )
  end
  it 'Global' do
    requests = nil
    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:render) do |*args|
      requests = args[3]
      []
    end
    eyes.check(Applitools::Selenium::Target.window())
    eyes.close_async
    runner.get_all_test_results(true)
    expect(requests.first.options).to eq(
      { 'option1' => 'value1', 'option2' => false }
    )
  end
  it 'Resetting' do
    requests = nil
    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:render) do |*args|
      requests = args[3]
      []
    end
    eyes.configure do |c|
      c.visual_grid_options = nil
    end
    eyes.check(Applitools::Selenium::Target.window())
    eyes.close_async
    runner.get_all_test_results(true)
    expect(requests.first.options).to be_empty
  end
end
