require 'spec_helper'

RSpec.describe 'Environment tests' do
  include Rspec::Shell::Expectations

  let(:stubbed_env) { create_stubbed_env }

  it 'ruby 1.9.3' do
    _stdout, _stderr, status = stubbed_env.execute(
      'docker run  -v $PWD/../:/source_dir -w /workdir ruby_2.1.10_suite' \
      ' /source_dir/environment_tests/spec/scripts/prepare_repo_and_run_tests.sh > log/1.9.3.log 2>&1'
    )
    expect(status.exitstatus).to eq 0
  end
end
