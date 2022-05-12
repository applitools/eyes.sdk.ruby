# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Applitools::MatchWindowData do
  let(:app_output) do
    Object.new.tap do |o|
      o.instance_eval do
        define_singleton_method :to_hash do
          :app_output
        end
      end
    end
  end

  let!(:value) { double }
  let(:app_output) { Applitools::AppOutput.new(nil, nil) }
  let(:a_screenshot) { Applitools::Screenshot.from_region(Applitools::Region.new(0, 0, 1, 1)) }
  let(:eyes_screenshot) { Applitools::EyesScreenshot.new(a_screenshot) }
  let(:app_output_with_screenshot) { Applitools::AppOutputWithScreenshot.new(app_output, eyes_screenshot) }

  it_should_behave_like 'responds to method', [
    :app_output,
    :app_output=,
    :user_inputs,
    :user_inputs=,
    :tag,
    :tag=,
    :options,
    :options=,
    :ignore_mismatch,
    :ignore_mismatch=,
    :exact,
    :exact=,
    :remainder,
    :remainder=,
    :scale,
    :scale=,
    :to_s,
    :to_hash,
    :use_dom,
    :use_dom=,
    :enable_patterns,
    :enable_patterns=
  ]

  context 'app_output=' do
    let(:app_output_hash) do
      {
        'Screenshot64' => 'Screenshot64_11',
        'ScreenshotUrl' => 'ScreenshotUrl_11',
        'Title' => 'Title_11',
        'IsPrimary' => 'IsPrimary_11',
        'Elapsed' => 'Elapsed_11',
        'Location' => { 'X' => 35, 'Y' => 46 }
      }
    end

    let(:app_output_hash_sym) do
      {
        'Screenshot64' => 'Screenshot64_11',
        'ScreenshotUrl' => 'ScreenshotUrl_11',
        'Title' => 'Title_11',
        'IsPrimary' => 'IsPrimary_11',
        'Elapsed' => 'Elapsed_11',
        'Location' => { X: 35, y: 46 }
      }
    end

    it 'accepts AppOutputWithScreenshot', pending: true do
      expect { subject.send(:app_output=, 123) }.to raise_error Applitools::EyesIllegalArgument
      expect { subject.send(:app_output=, app_output_with_screenshot) }.to_not raise_error
    end
    it 'iterates over keys', pending: true do
      expect(app_output_with_screenshot).to receive(:to_hash).and_return(app_output_hash)
      %w(Screenshot64 ScreenshotUrl Title IsPrimary Elapsed Location). each do |key|
        expect(subject.send(:current_data)['AppOutput']).to receive(:[]=).with(key, app_output_hash[key])
      end
      subject.app_output = app_output_with_screenshot
    end
    it 'handles \'location\'', pending: true do
      expect(app_output_with_screenshot).to receive(:to_hash).and_return(app_output_hash_sym)
      subject.app_output = app_output_with_screenshot
      expect(subject.send(:current_data)['AppOutput']['Location']['X']).to eq 35
      expect(subject.send(:current_data)['AppOutput']['Location']['Y']).to eq 46
    end
  end

  context 'exact' do
    it 'reads options=> match_window_settings=>exact key', pending: true do
      expect(subject.send(:current_data)['Options']['ImageMatchSettings']['Exact'].object_id)
        .to eq subject.exact.object_id
    end
  end

  context 'exact=', pending: true do
    it 'accepts hash or nil', pending: true do
      expect { subject.exact = {} }.to_not raise_error
      expect { subject.exact = nil }.to_not raise_error
      expect { subject.exact = 'String' }.to raise_error Applitools::EyesError
    end
    it 'iterates over keys' do
      value = {}
      current_exact = subject.send('current_data')['Options']['ImageMatchSettings']['Exact']
      %w(MinDiffIntensity MinDiffWidth MinDiffHeight MatchThreshold).each do |k|
        expect(value).to receive('[]').with(k)
        expect(current_exact).to receive('[]=').with(k, any_args)
      end
      subject.exact = value
    end
    it 'sets options=>match_window_settings=>exact key' do
      expect(subject.send('current_data')['Options']['ImageMatchSettings']).to receive('[]=').with('Exact', any_args)
      subject.exact = {}
    end
  end

  context 'remainder', pending: true do
    it 'reads options=>match_window_settings=>remainder key' do
      expect(subject.send(:current_data)['Options']['ImageMatchSettings']['remainder'].object_id)
        .to eq subject.remainder.object_id
    end
  end
  context 'remainder=' do
    it 'sets options=>match_window_settings=>remainder key' do
      subject.remainder = value
      expect(subject.remainder.object_id).to eq value.object_id
    end
  end
  context 'scale', pending: true do
    it 'reads options=>match_window_settings=>scale key' do
      expect(subject.send(:current_data)['Options']['ImageMatchSettings']['scale'].object_id)
        .to eq subject.scale.object_id
    end
  end
  context 'scale=' do
    it 'sets options=>match_window_settings=>scale key' do
      subject.scale = value
      expect(subject.scale.object_id).to eq value.object_id
    end
  end

  context 'results' do
    it 'returns data as hash' do
      result = subject.to_hash
      expect(result).to be_kind_of Hash
      expect(result.keys).to include('UserInputs', 'AppOutput', 'Tag', 'IgnoreMismatch')
    end

    it 'raises an error for unconverted ignored regions coordinates' do
      subject.instance_variable_set(:@need_convert_ignored_regions_coordinates, true)
      expect { subject.to_hash }.to raise_error Applitools::EyesError
    end

    it 'raises an error for unconverted floating regions coordinates' do
      subject.instance_variable_set(:@need_convert_floating_regions_coordinates, true)
      expect { subject.to_hash }.to raise_error Applitools::EyesError
    end
  end

  it 'updates ignored regions', pending: true do
    expect(subject.send(:current_data)['Options']['ImageMatchSettings']['Ignore']).to receive(:<<).with(kind_of(Hash))
    subject.ignored_regions = [Applitools::Region::EMPTY]
  end
  it 'updates floating regions', pending: true do
    expect(subject.send(:current_data)['Options']['ImageMatchSettings']['Floating']).to receive(:<<).with(kind_of(Hash))
    subject.floating_regions = [Applitools::FloatingRegion.new(0, 0, 0, 0, 0, 0, 0, 0)]
  end

  context 'read_target' do
    let(:options) { { test_method: false } }
    let(:target) do
      double.tap do |t|
        allow(t).to receive(:options).and_return options
        allow(t).to receive(:ignored_regions).and_return []
        allow(t).to receive(:floating_regions).and_return []
      end
    end

    it_should_behave_like 'responds to method', [
      :trim=,
      :ignore_caret=
    ]

    it 'iterates over options' do
      expect(subject.send(:target_options_to_read)).to(
        include('trim', 'ignore_caret', 'match_level', 'ignore_mismatch', 'exact')
      )
    end

    it 'skips empty options' do
      allow(subject).to receive(:target_options_to_read).and_return %w(another_test_method)
      expect(subject).to_not receive(:test_method=)
      subject.read_target target, nil
    end

    it 'uses field= method to set data' do
      allow(subject).to receive(:target_options_to_read).and_return %w(test_method)
      expect(subject).to receive(:test_method=)
      expect(options).to receive('[]').with(:test_method).and_call_original

      subject.read_target target, nil
    end

    context 'ignored_regions' do
      before do
        allow(target).to receive(:ignored_regions).and_return(
          [proc { Applitools::Region::EMPTY }, Applitools::Region::EMPTY]
        )
      end

      it 'iterates over ignored regions', pending: true do
        expect(subject.instance_variable_get(:@ignored_regions)).to receive(:<<).with(kind_of(Applitools::Region)).twice
        subject.read_target(target, nil)
      end
      it 'sets @need_convert_ignored_regions_coordinates to true' do
        expect(subject.instance_variable_get(:@need_convert_ignored_regions_coordinates)).to be false
        subject.read_target(target, nil)
        expect(subject.instance_variable_get(:@need_convert_ignored_regions_coordinates)).to be true
      end
    end
    context 'floating regions' do
      let(:f_region) { Applitools::FloatingRegion.new 0, 0, 0, 0, 0, 0, 0, 0 }
      let(:f_region_to_scale) { Applitools::FloatingRegion.new(10,10, 100, 200, 5, 5, 5, 5) }
      let(:f_region_scaled) { Applitools::FloatingRegion.new(10,10, 50, 100, 5, 5, 5, 5) }
      before do
        allow(target).to receive(:floating_regions).and_return [proc { f_region }, f_region]
      end

      it 'iterates over floating regions' do
        expect(subject.instance_variable_get(:@floating_regions)).to(
          receive(:<<).with(kind_of(Applitools::FloatingRegion)).twice
        )
        subject.read_target(target, nil)
      end
      it 'sets @need_convert_floating_regions_coordinates to true' do
        expect(subject.instance_variable_get(:@need_convert_floating_regions_coordinates)).to be false
        subject.read_target(target, nil)
        expect(subject.instance_variable_get(:@need_convert_floating_regions_coordinates)).to be true
      end

      # it 'converts coordinates' do
      #   allow(target).to receive(:floating_regions).and_return [f_region_to_scale]
      #   subject.read_target(target, nil)
      #   expect(subject.instance_variable_get(:@floating_regions).first).to eq(f_region_scaled)
      # end
    end

    context 'convert floating regions locations' do
      let(:f_region) { Applitools::FloatingRegion.new 10, 15, 40, 60, 40, 50, 60, 70 }
      let(:the_app_output) do
        instance_double(Applitools::AppOutputWithScreenshot).tap do |o|
          allow(o).to receive(:screenshot).and_return(the_screenshot)
        end
      end
      let(:the_screenshot) do
        instance_double(Applitools::Selenium::EyesScreenshot).tap do |o|
          allow(o).to receive(:convert_region_location).and_return(Applitools::Region.new(110, 115, 20, 30))
        end
      end

      before do
        allow(target).to receive(:floating_regions).and_return [proc { f_region }, f_region]
        allow(subject).to receive(:app_output).and_return(the_app_output)
      end

      it 'results class is Applitools::FloatingRegion' do
        subject.read_target(target, nil)
        expect(subject).to receive(:floating_regions=) do |value|
          value.each do |r|
            expect(r).to be_a(Applitools::FloatingRegion)
          end
        end
        subject.convert_floating_regions_coordinates
      end
      it 'results values validity' do
        subject.read_target(target, nil)
        expect(subject).to receive(:floating_regions=) do |value|
          value.each do |r|
            expect(r.left).to be 110
            expect(r.top).to be 115
            expect(r.width).to be 20
            expect(r.height).to be 30
            expect(r.max_left_offset).to be 40
            expect(r.max_top_offset).to be 50
            expect(r.max_right_offset).to be 60
            expect(r.max_bottom_offset).to be 70
          end
        end
        subject.convert_floating_regions_coordinates
      end
    end
  end

  context 'ignore_caret=' do
    it 'sets a value in result hash', pending: true do
      subject.ignore_caret = true
      expect(subject.send(:current_data)['Options']['ImageMatchSettings']['IgnoreCaret']).to be true
      subject.ignore_caret = false
      expect(subject.send(:current_data)['Options']['ImageMatchSettings']['IgnoreCaret']).to be false
    end
  end

  describe ':default_data' do
    let(:default_data) { described_class.default_data }
    subject { default_data }
    it 'is a hash' do
      expect(subject).to be_a Hash
    end

    it 'has required keys', pending: true do
      expect(subject.keys).to contain_exactly(
        'AppOutput',
        'Id',
        'IgnoreMismatch',
        'MismatchWait',
        'Options',
        'Tag',
        'UserInputs'
      )
    end

    it 'default values' do
      expect(subject['IgnoreMismatch']).to eq false
      expect(subject['MismatchWait']).to be_zero
    end

    describe '[\'AppOutput\']' do
      subject { default_data['AppOutput'] }
      it 'has required keys' do
        expect(subject).to be_a Hash
        expect(subject.keys).to contain_exactly(
          'Elapsed',
          'IsPrimary',
          'Screenshot64',
          'ScreenshotUrl',
          'Title',
          'Location'
        )
      end

      it 'has default values' do
        expect(subject['Elapsed']).to be_zero
        expect(subject['IsPrimary']).to eq false
        expect(subject['Location'].keys).to contain_exactly('X', 'Y')
        expect(subject['Location']['X']).to eq(0)
        expect(subject['Location']['Y']).to eq(0)
      end
    end

    describe '[\'options\']' do
      subject { default_data['Options'] }
      it 'has required keys', pending: true do
        expect(subject).to be_a Hash
        expect(subject.keys).to contain_exactly(
          'Name',
          'UserInputs',
          'ImageMatchSettings',
          'IgnoreExpectedOutputSettings',
          'ForceMatch',
          'ForceMismatch',
          'IgnoreMatch',
          'IgnoreMismatch',
          'Trim'
        )
      end

      it 'has default values' do
        expect(subject['UserInputs']).to be_a Array
        expect(subject['UserInputs']).to be_empty

        expect(subject['IgnoreExpectedOutputSettings']).to eq false
        expect(subject['ForceMatch']).to eq false
        expect(subject['ForceMismatch']).to eq false
        expect(subject['IgnoreMatch']).to eq false
        expect(subject['IgnoreMismatch']).to eq false
      end

      describe '[\'Trim\']' do
        subject { default_data['Options']['Trim'] }
        it 'has requirede keys' do
          expect(subject).to be_a Hash
          expect(subject.keys).to contain_exactly(
            'Enabled'
          )
        end

        it 'has default values' do
          expect(subject['Enabled']).to eq false
        end
      end

      describe '[\'ImageMatchSettings\']' do
        subject { default_data['Options']['ImageMatchSettings'] }
        it 'has required keys', pending: true do
          expect(subject).to be_a Hash
          expect(subject.keys).to contain_exactly(
            'Exact',
            'IgnoreCaret',
            'MatchLevel',
            'SplitBottomHeight',
            'SplitTopHeight',
            'Ignore',
            'Floating',
            'remainder',
            'scale',
            'UseDom',
            'EnablePatterns'
          )
        end

        it 'has default values', pending: true do
          expect(subject['IgnoreCaret']).to eq true
          expect(subject['MatchLevel']).to eq 'Strict'
          expect(subject['SplitBottomHeight']).to be_zero
          expect(subject['SplitTopHeight']).to be_zero
          expect(subject['Ignore']).to be_kind_of Array
          expect(subject['Ignore']).to be_empty
          expect(subject['Floating']).to be_kind_of Array
          expect(subject['Floating']).to be_empty
          expect(subject['remainder']).to be_zero
          expect(subject['scale']).to be_zero
        end

        describe '[\'Exact\']' do
          subject { default_data['Options']['ImageMatchSettings']['Exact'] }
          it 'has requirede keys', pending: true do
            expect(subject).to be_a Hash
            expect(subject.keys).to contain_exactly(
              'MatchThreshold',
              'MinDiffHeight',
              'MinDiffIntensity',
              'MinDiffWidth'
            )
          end

          it 'has default values', pending: true do
            expect(subject['MatchThreshold']).to be_zero
            expect(subject['MinDiffHeight']).to be_zero
            expect(subject['MinDiffIntensity']).to be_zero
            expect(subject['MinDiffWidth']).to be_zero
          end
        end
      end
    end
  end
end
