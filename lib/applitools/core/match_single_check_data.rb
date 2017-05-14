require_relative 'match_window_data'
module Applitools
  class MatchSingleCheckData < MatchWindowData
    class << self
      def default_data
        {
          'startInfo' => {
            'agentId' => nil,
            'appIdOrName' => nil,
            'verId' => nil,
            'scenarioIdOrName' => nil,
            'batchInfo' => {},
            'envName' => nil,
            'environment' => {},
            'defaultMatchSettings' => nil,
            'branchName' => nil,
            'parentBranchName' => nil
          },
          'IgnoreMismatch' => false,
          'MismatchWait' => 0,
          'Options' => {
            'Name' => nil,
            'UserInputs' => [],
            'ImageMatchSettings' => {
              'MatchLevel' => 'None',
              'SplitTopHeight' => 0,
              'SplitBottomHeight' => 0,
              'IgnoreCaret' => false,
              'Ignore' => [],
              'Exact' => {
                'MinDiffIntensity' => 0,
                'MinDiffWidth' => 0,
                'MinDiffHeight' => 0,
                'MatchThreshold' => 0
              }
            },
            'IgnoreExpectedOutputSettings' => false,
            'ForceMatch' => false,
            'ForceMismatch' => false,
            'IgnoreMatch' => false,
            'IgnoreMismatch' => false,
            'Trim' => {
              'Enabled' => false,
              'ForegroundIntensity' => 0,
              'MinEdgeLength' => 0
            }
          },
          'Id' => nil,
          'UserInputs' => [],
          'AppOutput' => {
            'Screenshot64' => nil,
            'ScreenshotUrl' => nil,
            'Title' => nil,
            'IsPrimary' => false,
            'Elapsed' => 0
          },
          'Tag' => nil,
          'updateBaselineIfDifferent' => false,
          'updateBaselineIfNew' => false
        }
      end
    end

    def start_info=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Applitools::SessionStartInfo
      hash_value = value.to_hash
      current_data['startInfo']['batchInfo'] = hash_value[:batch_info]
      current_data['startInfo']['environment'] = hash_value[:environment]
      current_data['startInfo']['agentId'] = hash_value[:agent_id]
      current_data['startInfo']['appIdOrName'] = hash_value[:app_id_or_name]
      current_data['startInfo']['verId'] = hash_value[:ver_id]
      current_data['startInfo']['scenarioIdOrName'] = hash_value[:scenario_id_or_name]
      current_data['startInfo']['envName'] = hash_value[:env_name]
      current_data['startInfo']['defaultMatchSettings'] = hash_value[:default_match_settings]
      current_data['startInfo']['branchName'] = hash_value[:branch_name]
      current_data['startInfo']['parentBranchName'] = hash_value[:parent_branch_name]
    end

    def update_baseline_if_different=(value)
      current_data['updateBaselineIfDifferent'] = value ? true : false
    end

    def update_baseline_if_new=(value)
      current_data['updateBaselineIfNew'] = value ? true : false
    end
  end
end
