# frozen_string_literal: true
require 'rspec'
require 'spec_helper'

RSpec.describe 'Config Object fields' do
  let(:eyes) { Applitools::Selenium::Eyes.new }
  let(:session_start_info) { eyes.send(:session_start_info) }
  let(:match_level) { session_start_info['start_info']['defaultMatchSettings']['matchLevel'] }
  let(:session_info) { Applitools::Session.new('id', 'url', true) }
  let(:driver) { Applitools::Selenium::Driver.new(eyes, {}) }
  let(:selenium_driver) { double }
  let(:new_config) { Applitools::Selenium::Configuration.new }
  before do
    allow(selenium_driver).to receive(:driver_for_eyes).and_return(driver)
    allow(Applitools::Utils::EyesSeleniumUtils).to receive(:extract_viewport_size).and_return(
      Applitools::RectangleSize.new(0, 0)
    )
    allow(driver).to receive(:manage)
  end

  context 'exact options' do
    before do
      allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:start_session) do |*args|
        expect(args.last.to_hash[:default_match_settings][:match_level]).to eq Applitools::MatchLevel::EXACT
        expect(args.last.to_hash[:default_match_settings][:exact]).to eq(
          'MinDiffIntensity' => 1,
          'MinDiffWidth' => 2,
          'MinDiffHeight' => 3,
          'MatchThreshold' => 4
        )
        expect(args.last.to_hash[:default_match_settings][:scale]).to eq 0
        expect(args.last.to_hash[:default_match_settings][:remainder]).to eq 0
        session_info
      end
    end

    context 'through the eyes' do
      it 'set_default_match_level' do
        eyes.set_default_match_settings(
          Applitools::MatchLevel::EXACT,
          min_diff_intensity: 1,
          min_diff_width: 2,
          min_diff_height: 3,
          match_threshold: 4
        )
        eyes.open(driver: selenium_driver, app_name: 'app_name', test_name: 'test_name')
      end
      it 'default_match_level=' do
        eyes.default_match_settings = {
          match_level: Applitools::MatchLevel::EXACT,
          exact: {
            min_diff_intensity: 1,
            min_diff_width: 2,
            min_diff_height: 3,
            match_threshold: 4
          },
          scale: 0,
          remainder: 0
        }
        eyes.open(driver: selenium_driver, app_name: 'app_name', test_name: 'test_name')
      end
    end
    context 'config object' do
      it 'set_default_match_level' do
        eyes.configure do |c|
          c.default_match_settings = {
            match_level: Applitools::MatchLevel::EXACT,
            exact: {
              min_diff_intensity: 1,
              min_diff_width: 2,
              min_diff_height: 3,
              match_threshold: 4
            },
            scale: 0,
            remainder: 0
          }
        end
        eyes.open(driver: selenium_driver, app_name: 'app_name', test_name: 'test_name')
      end
      it 'default_match_level=' do
        eyes.configure do |c|
          c.set_default_match_settings(
            Applitools::MatchLevel::EXACT,
            min_diff_intensity: 1,
            min_diff_width: 2,
            min_diff_height: 3,
            match_threshold: 4
          )
        end
        eyes.open(driver: selenium_driver, app_name: 'app_name', test_name: 'test_name')
      end
    end
  end

  context 'default match level' do
    before do
      allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:start_session) do |*args|
        expect(args.last.to_hash[:default_match_settings][:match_level]).to eq Applitools::MatchLevel::STRICT
        expect(args.last.to_hash[:default_match_settings][:exact]).to be nil
        session_info
      end
    end

    context 'through the eyes' do
      it { eyes.open(driver: selenium_driver, app_name: 'app_name', test_name: 'test_name') }
    end

    context 'config object' do
      it do
        eyes.config = new_config
        eyes.open(driver: selenium_driver, app_name: 'app_name', test_name: 'test_name')
      end
    end
  end

  context 'Match Level' do
    before do
      allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:start_session) do |*args|
        expect(args.last.to_hash[:default_match_settings][:match_level]).to eq Applitools::MATCH_LEVEL[:layout]
        expect(args.last.to_hash[:default_match_settings][:exact]).to be nil
        session_info
      end
    end

    it 'Passes eyes.match_level to session_start_info' do
      eyes.match_level = Applitools::MATCH_LEVEL[:layout]
      eyes.open(driver: selenium_driver, app_name: 'app_name', test_name: 'test_name')
    end

    it 'Passes config.match_level to session_start_info' do
      eyes.configure do |c|
        c.match_level = Applitools::MATCH_LEVEL[:layout]
      end
      eyes.open(driver: selenium_driver, app_name: 'app_name', test_name: 'test_name')
    end

    it 'raises an error if match_level is invalid' do
      expect { eyes.match_level = 'WRONG' }.to raise_error Applitools::EyesError
    end

    it 'sets the default match level to Strict' do
      allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:start_session) do |*args|
        expect(args.last.to_hash[:default_match_settings][:match_level]).to eq Applitools::MATCH_LEVEL[:strict]
        session_info
      end
      eyes.open(driver: selenium_driver, app_name: 'app_name', test_name: 'test_name')
    end
  end
end
