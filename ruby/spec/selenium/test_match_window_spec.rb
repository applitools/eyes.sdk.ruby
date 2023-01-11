RSpec.shared_examples 'ReplaceMatchedStep' do |url, expected_replace_last_list|
  it 'testReplaceMatchedStep' do
    begin
      driver.get(url)
      eyes.check_window('Step 1')
      eyes.close_async
    ensure
      eyes.abort_if_not_closed
      runner.get_all_test_results(false)
    end
    expect(replace_last_list).to eq(expected_replace_last_list)
  end
end

RSpec.describe 'TestMatchWindow', mock_connection: true, skip: true do
  before(:all) do
    $local_classic_runner ||= Applitools::ClassicRunner.new
    Applitools::EyesLogger.log_handler = Logger.new(STDOUT)
  end
  let(:web_driver) { Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: [:headless]) }
  let(:runner) { $local_classic_runner }
  let(:eyes) { Applitools::Selenium::Eyes.new(runner: runner) }

  let(:driver) { eyes.open(app_name: 'Applitools Eyes SDK', test_name: 'testReplaceMatchedStep', driver: web_driver, viewport_size: {width: 700, height: 460})}
  let(:replace_last_list) { [] }
  after do
    driver.quit
  end

  before do
    allow_any_instance_of(Applitools::Session).to receive(:new_session?).and_return(false)
    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:match_window) do |_this, _session, data|
      replace_last_list.push(data.replace_last)
      Applitools::MatchResult.new('asExpected' => false)
    end
  end
  it_should_behave_like 'ReplaceMatchedStep', 'https://applitools.github.io/demo/TestPages/SpecialCases/neverchanging.html', [false]
  it_should_behave_like 'ReplaceMatchedStep', 'https://applitools.github.io/demo/TestPages/SpecialCases/everchanging.html', [false, true, true]
end