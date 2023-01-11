# frozen_string_literal: true

RSpec.describe 'Default config values for Selenium' do
  let(:configuration) { Applitools::Selenium::Configuration.new }
  let(:runner) { Applitools::ClassicRunner.new }
  let(:eyes) { Applitools::Selenium::Eyes.new(runner: runner) }
  context 'hide_scrollbars' do
    it 'in configuration' do
      expect(configuration.hide_scrollbars).to be_truthy
    end
    it 'in an Eyes instance' do
      expect(eyes.hide_scrollbars).to be_truthy
    end
  end
  context 'ignore_caret' do
    it 'in configuration' do
      expect(configuration.ignore_caret).to be_truthy
    end
    it 'in an Eyes instance' do
      expect(eyes.ignore_caret).to be_truthy
    end
    it 'passes to image_match_settings' do
      configuration.ignore_caret = false
      expect(configuration.default_match_settings.ignore_caret).to be_falsey
    end
  end
end
