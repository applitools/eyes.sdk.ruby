# frozen_string_literal: true
require 'eyes_selenium'

RSpec.shared_examples 'clone configuration' do
  before(:each) { eyes.configuration = original_configuration }
  it ':configuration returns clone of the config object' do
    expect(eyes.configuration.object_id).to_not eq(original_configuration.object_id)
  end

  it 'returned config is the same as original' do
    conf = eyes.configuration
    original_configuration.config_keys.each do |k|
      expect(conf.send(k)).to eq(original_configuration.send(k))
    end
  end

  it 'all values should be cloned' do
    conf = eyes.configuration
    original_configuration.config_keys.each do |k|
      # rubocop:disable Lint/UnifiedInteger
      unless [NilClass, TrueClass, FalseClass, Integer, Float, Symbol].include? conf.send(k).class
        expect(conf.send(k).object_id).to_not eq(original_configuration.send(k).object_id)
      end
      # rubocop:enable Lint/UnifiedInteger
    end
  end

  it 'has get_configuration & set_configuration methods' do
    expect(eyes).to respond_to(:get_configuration)
    expect(eyes).to respond_to(:set_configuration)
  end
end

RSpec.describe 'Clone config for EyesBase' do
  it_should_behave_like 'clone configuration'
  let(:original_configuration) { Applitools::EyesBaseConfiguration.new }
  let(:eyes) { Applitools::EyesBase.new }
end

RSpec.describe 'Clone config for VisualGridEyes' do
  it_should_behave_like 'clone configuration'
  let(:original_configuration) { Applitools::Selenium::Configuration.new }
  let(:eyes) { Applitools::Selenium::VisualGridEyes.new(runner: double) }
end

RSpec.describe 'Clone config for SeleniumEyes' do
  it_should_behave_like 'clone configuration'
  let(:original_configuration) { Applitools::Selenium::Configuration.new }
  let(:eyes) { Applitools::Selenium::SeleniumEyes.new(runner: double) }
end
