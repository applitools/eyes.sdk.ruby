require 'spec_helper'

RSpec.describe Applitools::Calabash::EnvironmentDetector do
  context 'Android' do
    before do
      Object.send(:remove_const, :Calabash) if Object.constants.include?(:Calabash)
      class_double('::Calabash::Android').as_stubbed_const
    end
    it 'detects android' do
      expect(described_class.android?).to be_truthy
    end
    it 'does not detect ios' do
      expect(described_class.ios?).to be_falsey
    end
    it 'detects environment' do
      expect(described_class.current_environment).to eq :android
    end
  end

  context 'iOS' do
    before do
      Object.send(:remove_const, :Calabash) if Object.constants.include?(:Calabash)
      class_double('::Calabash::Cucumber').as_stubbed_const
    end
    it 'detects ios' do
      expect(described_class.ios?).to be_truthy
    end
    it 'does not detect android' do
      expect(described_class.android?).to be_falsy
    end
    it 'detects environment' do
      expect(described_class.current_environment).to eq :ios
    end
  end

  context 'No environment' do
    it 'raises error' do
      expect { described_class.current_environment }.to raise_error(Applitools::EyesError)
    end
  end
end
