# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Applitools::Calabash::Target' do
  let(:valid_region) do
    {
      'rect' => {
        'x' => 50,
        'y' => 51,
        'width' => 60,
        'height' => 61,
        'center_x' => 1,
        'center_y' => 2
      }
    }
  end
  let(:calabash_element) { Applitools::Calabash::CalabashElement.new valid_region, '*' }
  subject { Applitools::Calabash::Target.new }
  describe 'accepts Applitools::Calabash::Element for' do
    it ':region' do
      subject.region(calabash_element)
      result = subject.region_to_check
      expect(result.left).to eq valid_region['rect']['x']
      expect(result.top).to eq valid_region['rect']['y']
      expect(result.width).to eq valid_region['rect']['width']
      expect(result.height).to eq valid_region['rect']['height']
    end

    it ':ignore' do
      subject.ignore(calabash_element)
      expect(subject.ignored_regions).to_not be_empty
      result = subject.ignored_regions.first
      expect(result.left).to eq valid_region['rect']['x']
      expect(result.top).to eq valid_region['rect']['y']
      expect(result.width).to eq valid_region['rect']['width']
      expect(result.height).to eq valid_region['rect']['height']
    end
  end

  describe ':region' do
    let(:region) { Applitools.region.new(0, 0, 10, 10) }
    it 'accepts Applitools::Region' do
      expect { subject.region }.to_not raise_error
    end
  end
end
