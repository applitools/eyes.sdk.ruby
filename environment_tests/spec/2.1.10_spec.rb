# frozen_string_literal: true

require 'spec_helper'
require 'support/run_in_docker'

RSpec.describe 'Ruby 2.1.10 environment' do
  it_behaves_like 'run in docker container', '2.1.10'
end
