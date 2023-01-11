# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'require step defenition file' do |file|
  let!(:required_files) { [] }
  before do
    allow(Applitools::Calabash).to receive(:require_environment)
    class_double('::Calabash::Android').as_stubbed_const
  end
  after { load 'applitools/calabash_steps.rb' }
  it file do
    expect(Applitools::Calabash).to receive(:require_environment).with(file, any_args).once
  end
end
RSpec.describe 'require eyes calabash steps' do
  context do
    it_behaves_like 'require step defenition file', 'applitools/calabash/steps/matchers'
    it_behaves_like 'require step defenition file', 'applitools/calabash/steps/eyes_session'
    it_behaves_like 'require step defenition file', 'applitools/calabash/steps/eyes_settings'
  end
end
