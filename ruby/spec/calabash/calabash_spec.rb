# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Applitools::Calabash do
  describe 'require_environment' do
    before do
      # allow(Applitools::Calabash).to receive(:load_dir).and_return('')
    end
    it 'does not require non-existing files' do
      expect(Object).to_not receive(:require)
      described_class.require_environment 'does_not_exist.rb', :android
      described_class.require_environment 'does_not_exist.rb', :ios
    end
    it 'requires main file' do
      expect(Applitools::Calabash).to receive(:require).with(/^.*matchers.rb$/).twice
      described_class.require_environment('applitools/calabash/steps/matchers', :android)
    end
    it 'requires environment dependent file' do
      expect(Applitools::Calabash).to receive(:require).with(/^.*matchers.rb$/).once
      expect(Applitools::Calabash).to receive(:require).with(/^.*ios_matchers.rb$/).once
      described_class.require_environment('applitools/calabash/steps/matchers', :ios)
    end
  end
end
