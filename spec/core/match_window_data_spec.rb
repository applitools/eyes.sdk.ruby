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
    :to_hash
  ]

  context 'exact' do
    it 'reads options=> match_window_settings=>exact key' do
      expect(subject.send(:current_data)['Options']['ImageMatchSettings']['Exact'].object_id)
        .to eq subject.exact.object_id
    end
  end

  context 'exact=' do
    it 'accepts hash or nil' do
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

  context 'remainder' do
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
  context 'scale' do
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

  it 'updates ignored regions' do
    expect(subject.send(:current_data)['Options']['ImageMatchSettings']['Ignore']).to receive(:<<).with(kind_of(Hash))
    subject.ignored_regions = [Applitools::Region::EMPTY]
  end
  it 'updates floating regions' do
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

      it 'iterates over ignored regions' do
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
      before do
        allow(target).to receive(:floating_regions).and_return [proc { f_region }, f_region]
      end

      it 'iterates over floating regions' do
        expect(subject.instance_variable_get(:@floating_regions)).to(
          receive(:<<).with(kind_of(Applitools::FloatingRegion)).twice
        )
        subject.read_target(target, nil)
      end
      it 'sets @need_convert_ignored_regions_coordinates to true' do
        expect(subject.instance_variable_get(:@need_convert_floating_regions_coordinates)).to be false
        subject.read_target(target, nil)
        expect(subject.instance_variable_get(:@need_convert_floating_regions_coordinates)).to be true
      end
    end
  end

  context 'ignore_caret=' do
    it 'sets a value in result hash' do
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

    it 'has required keys' do
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
          'Title'
        )
      end

      it 'has default values' do
        expect(subject['Elapsed']).to be_zero
        expect(subject['IsPrimary']).to eq false
      end
    end

    describe '[\'options\']' do
      subject { default_data['Options'] }
      it 'has required keys' do
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
        it 'has required keys' do
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
            'scale'
          )
        end

        it 'has default values' do
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
          it 'has requirede keys' do
            expect(subject).to be_a Hash
            expect(subject.keys).to contain_exactly(
              'MatchThreshold',
              'MinDiffHeight',
              'MinDiffIntensity',
              'MinDiffWidth'
            )
          end

          it 'has default values' do
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
