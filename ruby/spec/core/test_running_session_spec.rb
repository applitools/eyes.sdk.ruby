RSpec.shared_examples 'TestStartSession_LongRequest_IsNewField' do |is_new|
  context "when isNew = #{is_new}" do
    let(:logger) { Logger.new(STDOUT) }

    let(:server_connector) do
      Applitools::Connectivity::ServerConnector.new.tap do |c|
        c.api_key = 'testKey'
      end
    end

    let(:session_properties) { [{name: 'property 1', value: 'value 1'}, {name: nil, value:nil}] }

    let(:batch_info) { Applitools::BatchInfo.new }

    let(:app_environment) do
      Applitools::AppEnvironment.new(
        os: 'windows',
        hosting_app: 'test suite',
        display_size: Applitools::RectangleSize.new(234, 456),
        # inferred_environment: '',
        device_info: 'Some Mobile Device'
      )
    end

    let(:default_match_settings) { Applitools::ImageMatchSettings.new }

    let(:start_info) do
      Applitools::SessionStartInfo.new(
          agent_id: 'agent', app_id_or_name: 'some app', ver_id: '1.0',
          scenario_id_or_name: 'some test', batch_info: batch_info,
          baseline_env_name: 'baseline', environment: app_environment,
          default_match_settings: default_match_settings,
          environment_name: 'some environment', branch_name: 'some branch',
          parent_branch_name: 'parent branch', baseline_branch_name: 'baseline branch',
          save_diffs: nil, properties: session_properties
      )
    end

    it 'TestStartSession_LongRequest_IsNewField' do

    end
  end
end


RSpec.describe 'TestRunningSession' do

  it 'TestStartSession_LongRequest_IsNewField' do

  end

  it 'TestStartSession_LongRequest_StatusCode' do

  end
end