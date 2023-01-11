require 'test_utils'
RSpec.describe 'Session start info' do
  let(:start_info) do
    Applitools::SessionStartInfo.new agent_id: 'base_agent_id', app_id_or_name: 'app_name',
      scenario_id_or_name: 'test_name', batch_info: Applitools::BatchInfo.new,
      environment: Applitools::AppEnvironment.new, environment_name: 'environment_name',
      default_match_settings: Applitools::ImageMatchSettings.new,
      branch_name: 'branch_name', parent_branch_name: 'parent_branch_name', properties: [], ver_id: 'ver_id',
      compare_with_parent_branch: 'compare_with_parent_branch', baseline_env_name: 'baseline_env_name',
      save_diffs: true, session_type: 'session_type', baseline_branch_name: 'baseline_branch_name'
  end
  it 'hash for json', report_me: true do
    expect(start_info.json_data).to be_a Hash
    expect(start_info.json_data[:startInfo][:batchInfo]).to be_a Hash
    expect(start_info.json_data[:startInfo][:environment]).to be_a Hash
    expect(start_info.json_data[:startInfo][:defaultMatchSettings]).to be_a Hash
    expect(start_info.json_data[:startInfo][:properties]).to be_a Array
    expect(start_info.json_data[:startInfo]).to include(
                                    :'agentId' => 'base_agent_id',
                                    :'appIdOrName' => 'app_name',
                                    :'branchName' => 'branch_name',
                                    :'compareWithParentBranch' => 'compare_with_parent_branch',
                                    # :'envName' => 'baseline_env_name',
                                    :'scenarioIdOrName' => 'test_name',
                                    :'verId' => 'ver_id',
                                    :sessionType => 'session_type',
                                    :baselineEnvName => 'baseline_env_name',
                                    :environmentName => 'environment_name',
                                    :parentBranchName => 'parent_branch_name',
                                    :baselineBranchName => 'baseline_branch_name',
                                    :saveDiffs => true
                                  )
  end
end
