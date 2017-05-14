require 'spec_helper'
require 'support/run_in_docker'

RSpec.describe 'Ruby 2.3.0 environment' do
  it_behaves_like 'run in docker container', '2.3.0'
end
