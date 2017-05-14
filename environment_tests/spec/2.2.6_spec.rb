require 'spec_helper'
require 'support/run_in_docker'

RSpec.describe 'Ruby 2.2.6 environment' do
  it_behaves_like 'run in docker container', '2.2.6'
end
