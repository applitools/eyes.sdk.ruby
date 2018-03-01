# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Applitools::Images::Eyes do
  let(:image) { ChunkyPNG::Image.new(5, 5) }
  let(:target) { Applitools::Images::Target.any(image) }
  before(:each) do
    subject.default_match_settings = { :match_level => :layout }
    allow(subject).to receive(:get_viewport_size).and_return(width: 800, height: 600)
    allow(subject).to receive(:app_environment).and_return(
      Applitools::AppEnvironment.new(
        :os => :host_os,
        :hosting_app => :host_app,
        :display_size => Applitools::RectangleSize.new(800, 600),
        :inferred => :inferred_environment
      )
    )
  end
  describe ':check_image' do
    it 'passes match_level to base' do
      expect(subject).to receive(:check_window_base) do |*opts|
        expect(opts.last.match_level).to eq 'Layout'
      end.and_return(Applitools::MatchResults.new)
      subject.check_image(tag: 'nil', image: image)
    end
  end

  describe ':check_region' do
    it 'passes match_level to base' do
      expect(subject).to receive(:check_window_base) do |*opts|
        expect(opts.last.match_level).to eq 'Layout'
      end.and_return(Applitools::MatchResults.new)
      subject.check_region(tag: 'nil', image: image, region: Applitools::Region::EMPTY)
    end
  end

  context ':check' do
    before do
      subject.api_key = 'API_KEY_FOR_TESTS'
      subject.open(app_name: 'app_name', test_name: 'test_name')
      allow_any_instance_of(Applitools::MatchWindowTask).to receive(:match_window)
        .and_return(Applitools::MatchResults.new.tap { |r| r.as_expected = false })
    end

    it 'calls check_it for actual check' do
      expect(subject).to receive('check_it').and_call_original
      subject.check('', target)
    end

    it 'performs \':read_target\' for match_data' do
      expect_any_instance_of(Applitools::MatchWindowData).to receive(:read_target)
      subject.check('', target)
    end

    it 'sets default values before \'reading\' target' do
      expect(subject).to receive(:update_default_settings)
        .with(Applitools::MatchWindowData).and_raise Applitools::EyesError
      expect_any_instance_of(Applitools::MatchWindowData).to_not receive(:read_target)
      begin
        subject.check('', target)
      rescue Applitools::EyesError
        subject
      end
    end

    it 'calls check_window_base' do
      expect(subject).to receive('check_window_base').and_call_original
      subject.check('', target)
    end

    it 'returns boolean' do
      expect(subject.check('', target)).to be(true).or be(false)
    end
  end

  context ':check_single' do
    before do
      subject.api_key = 'API_KEY_FOR_TESTS'
      allow_any_instance_of(Applitools::MatchSingleTask).to receive(:match_window)
        .and_return(Applitools::TestResults.new(:key => :value))
    end

    it 'wraps code with open_and_close' do
      expect(subject).to receive('open_and_close').and_call_original
      subject.check_single('test', target, app_name: 'app_name', test_name: 'test_name')
    end

    it 'calls check_it for actual check' do
      expect(subject).to receive('check_it')
      subject.check_single('', target, app_name: 'app_name', test_name: 'test_name')
    end

    it 'performs \':read_target\' for match_data' do
      expect_any_instance_of(Applitools::MatchWindowData).to receive(:read_target)
      subject.check_single('', target, app_name: 'app_name', test_name: 'test_name')
    end

    it 'sets default values before \'reading\' target' do
      expect(subject).to receive(:update_default_settings)
        .with(Applitools::MatchWindowData).and_raise Applitools::EyesError
      expect_any_instance_of(Applitools::MatchWindowData).to_not receive(:read_target)
      begin
        subject.check_single('', target, app_name: 'app_name', test_name: 'test_name')
      rescue Applitools::EyesError
        subject
      end
    end

    it 'calls check_single_base' do
      expect(subject).to receive('check_single_base').and_call_original
      subject.check_single('', target, app_name: 'app_name', test_name: 'test_name')
    end

    it 'returns match_result' do
      expect(subject.check_single('', target, app_name: 'app_name', test_name: 'test_name')).to match(:key => :value)
    end
  end
end
