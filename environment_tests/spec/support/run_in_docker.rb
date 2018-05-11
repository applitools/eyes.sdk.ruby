# frozen_string_literal: true

RSpec.shared_examples 'run in docker container' do |dockerfile|
  include Rspec::Shell::Expectations

  let(:stubbed_env) { create_stubbed_env }
  it "ruby #{dockerfile}" do
    _stdout, _stderr, status = stubbed_env.execute(
      "docker run  --rm -v $PWD/../:/source_dir -w /workdir #{dockerfile} " \
      "/source_dir/environment_tests/spec/scripts/prepare_repo_and_run_tests.sh > log/#{dockerfile}.log 2>&1"
    )
    expect(status.exitstatus).to eq 0
  end
end
