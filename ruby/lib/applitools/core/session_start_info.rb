# frozen_string_literal: true

module Applitools
  class SessionStartInfo
    include Applitools::Jsonable
    json_fields :batchInfo, :agentId, :appIdOrName, :verId, :environment, :environmentName, :branchName, :defaultMatchSettings,
      :scenarioIdOrName, :properties, :parentBranchName, :compareWithParentBranch, :baselineEnvName, :saveDiffs, :sessionType,
      :baselineBranchName, :agentRunId

    wrap_data do |value|
      { startInfo: value }
    end

    def initialize(options = {})
      self.agent_id = options[:agent_id]
      self.app_id_or_name = options[:app_id_or_name]
      self.ver_id = options[:ver_id]
      self.scenario_id_or_name = options[:scenario_id_or_name]
      self.batch_info = options[:batch_info]
      self.environment_name = options[:environment_name]
      self.baseline_env_name = options[:baseline_env_name]
      self.environment = options[:environment]
      self.default_match_settings = options[:default_match_settings]
      self.branch_name = options[:branch_name]
      self.parent_branch_name = options[:parent_branch_name]
      self.properties = options[:properties]
      self.compare_with_parent_branch = options[:compare_with_parent_branch]
      self.save_diffs = options[:save_diffs]
      self.session_type = options[:session_type]
      self.baseline_branch_name = options[:baseline_branch_name]
      self.agentRunId = options[:agent_run_id] if options[:agent_run_id]
    end

    def to_hash
      json_data
    end
  end
end
