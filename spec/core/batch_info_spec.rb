# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Applitools::BatchInfo, clear_environment: true do
  it_behaves_like 'has environment attribute', :name, 'APPLITOOLS_BATCH_NAME'
  it_behaves_like 'has environment attribute', :id, 'APPLITOOLS_BATCH_ID'

  it 'creates a new id if nothing was passed' do
    expect(subject.id).to_not be nil
  end
  it 'uses id from environment variable if passed' do
    allow(Applitools::Helpers.instance_variable_get(:@environment_variables)).to(
      receive(:[]).with('APPLITOOLS_BATCH_ID'.to_sym).and_return('myID')
    )
    expect(subject.id).to eq 'myID'
  end
  it 'a passed name takes precedence over environment variable' do
    allow(Applitools::Helpers.instance_variable_get(:@environment_variables)).to(
      receive(:[]).with('APPLITOOLS_BATCH_ID'.to_sym)
    )
    allow(Applitools::Helpers.instance_variable_get(:@environment_variables)).to(
      receive(:[]).with('APPLITOOLS_BATCH_NAME'.to_sym).and_return('NAME')
    )
    batch_info = described_class.new('A_NEW_NAME')
    expect(batch_info.name).to eq 'A_NEW_NAME'
  end
end
