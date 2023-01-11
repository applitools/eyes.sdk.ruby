# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Applitools::BatchInfo, clear_environment: true do
  it_behaves_like 'has environment attribute', :name, 'APPLITOOLS_BATCH_NAME'
  it_behaves_like 'has environment attribute', :id, 'APPLITOOLS_BATCH_ID'
  it_behaves_like 'has environment attribute', :env_notify_on_completion, 'APPLITOOLS_BATCH_NOTIFY'

  before do
    allow(Applitools::Helpers.instance_variable_get(:@environment_variables)).to(
        receive(:[]).with(any_args).and_return('')
    )
  end

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
  context 'handles environment variable APPLITOOLS_BATCH_NOTIFY' do
    it 'true' do
      allow(Applitools::Helpers.instance_variable_get(:@environment_variables)).to(
          receive(:[]).with('APPLITOOLS_BATCH_NOTIFY'.to_sym).and_return('true')
      )
      expect(subject.notify_on_completion).to be_truthy
    end

    it 'false' do
      allow(Applitools::Helpers.instance_variable_get(:@environment_variables)).to(
          receive(:[]).with('APPLITOOLS_BATCH_NOTIFY'.to_sym).and_return('false')
      )
      expect(subject.notify_on_completion).to be_falsey
    end

    it 'default' do
      expect(subject.notify_on_completion).to be_falsey
    end

    it 'manual settings' do
      subject.notify_on_completion = true
      expect(subject.notify_on_completion).to be_truthy
      subject.notify_on_completion = false
      expect(subject.notify_on_completion).to be_falsey
    end

    it 'json value' do
      expect(subject.json_data['notifyOnCompletion']).to be_falsey
      subject.notify_on_completion = true
      expect(subject.json_data['notifyOnCompletion']).to be_truthy
    end
  end
end
