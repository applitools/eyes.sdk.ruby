# frozen_string_literal: true

RSpec.describe Applitools::Region do
  subject { described_class.new(9, 10, 11, 12) }
  context 'padding' do
    let(:valid_padding) { Applitools::PaddingBounds.new(10, 11, 12, 13) }

    it 'respond to :padding' do
      expect(subject).to respond_to :padding
    end

    it 'respond to :with_padding' do
      expect(subject).to respond_to :with_padding
    end

    it 'padding returns self' do
      expect(subject.padding(valid_padding).object_id).to eq subject.object_id
    end

    it 'resets padding if called without arguments' do
      subject.padding(valid_padding)
      expect(subject.padding).to have_attributes(
        padding_top: 0,
        padding_left: 0,
        padding_right: 0,
        padding_bottom: 0
      )
    end

    it 'has zero padding by default' do
      expect(subject).to have_attributes(
        padding_top: 0,
        padding_left: 0,
        padding_right: 0,
        padding_bottom: 0
      )
    end

    it 'padding accepts Applitools::PaddingBounds as an argument' do
      expect { subject.padding('not valid string') }.to raise_error Applitools::EyesError
      expect { subject.padding(valid_padding) }.to_not raise_error
    end

    it 'with_padding returns new instance which includes paddings' do
      expect(subject.padding(valid_padding).with_padding.to_hash).to include(
        left: -1,
        top: -1,
        width: 33,
        height: 36
      )
    end
  end
end
