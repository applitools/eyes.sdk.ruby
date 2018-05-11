# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Applitools::FloatingRegion do
  subject { Applitools::FloatingRegion.new 0, 0, 0, 0, 0, 0, 0, 0 }

  let(:original_element) do
    instance_double(Selenium::WebDriver::Element).tap do |el|
      allow(el).to receive(:location).and_return Applitools::Location.new(0, 0)
      allow(el).to receive(:size).and_return Applitools::RectangleSize.new(0, 0)
    end
  end

  let(:element) { Applitools::Selenium::Element.new nil, original_element }
  let(:bounds) { Applitools::FloatingBounds.new(10, 10, 10, 10) }
  let(:region) { Applitools::Region.new(10, 10, 10, 10) }

  it 'can be created from an element' do
    expect(described_class).to respond_to :any
    expect { described_class.any(nil, 0, 0, 0, 0) }.to raise_error Applitools::EyesError
    expect { described_class.any(element, 0, 0, 0, 0) }.to_not raise_error
  end

  it 'can be created from region and bounds' do
    fr = nil
    expect { fr = described_class.any(element, bounds) }.to_not raise_error
    expect { described_class.new(region, bounds) }.to_not raise_error
    expect(fr).to be_a_kind_of Applitools::FloatingRegion
  end

  it 'can be created from plain coordinates' do
    expect { described_class.new(10, 10, 10, 10, 10, 10, 10, 10) }.to_not raise_error
  end

  it_should_behave_like 'responds to method', [:to_hash]

  context 'padding' do
    let(:valid_padding) { Applitools::PaddingBounds.new(10, 11, 12, 13) }

    it 'respond to :padding' do
      expect(subject).to respond_to :padding
    end

    it 'padding accepts Applitools::PaddingBounds as an argument' do
      expect { subject.padding('not valid string') }.to raise_error Applitools::EyesError
      expect { subject.padding(valid_padding) }.to_not raise_error
    end

    it 'adds padding bounds to an external rectangle' do
      expect(subject.padding(valid_padding).to_hash).to include(
        'MaxLeftOffset' => 10,
        'MaxRightOffset' => 12,
        'MaxUpOffset' => 11,
        'MaxDownOffset' => 13
      )
    end
  end

  context 'to_hash' do
    it 'conteins necessary keys' do
      expect(subject.to_hash.keys).to contain_exactly(
        'Top', 'Left', 'Width', 'Height', 'MaxLeftOffset', 'MaxRightOffset', 'MaxUpOffset', 'MaxDownOffset'
      )
    end
  end
end
