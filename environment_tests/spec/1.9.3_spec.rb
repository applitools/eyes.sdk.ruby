# frozen_string_literal: true

require 'spec_helper'
require 'support/run_in_docker'

RSpec.describe 'Ruby 1.9.3 environment' do
  it_behaves_like 'run in docker container', '1.9.3'
end
