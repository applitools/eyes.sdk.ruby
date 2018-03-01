# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Applitools::Calabash::EyesCalabashScreenshot do
  let(:empty_region) { Applitools::Region::EMPTY }
  let(:non_empty_region) { Applitools::Region.new(10, 11, 12, 13) }

  subject do
    described_class.new(Applitools::Screenshot.from_image(::ChunkyPNG::Image.new(5, 5)))
  end

  it_behaves_like(
    'has abstract method',
    convert_region_location: [Applitools::Location::TOP_LEFT, Applitools::Calabash::EyesCalabashScreenshot::DRIVER]
  )

  it_behaves_like 'has private method', [:bounds]

  it 'has bounds as an image size' do
    bounds = subject.send(:bounds)
    expect(bounds.x).to eq 0
    expect(bounds.y).to eq 0
    expect(bounds.width).to eq 5
    expect(bounds.height).to eq 5
  end

  it ':location_in_screenshot is prohibited' do
    expect { subject.location_in_screenshot(0, 0) }.to raise_error Applitools::EyesError
  end
  it ':convert_location is prohibited' do
    expect { subject.convert_location(0, 0, 0) }.to raise_error Applitools::EyesError
  end

  context 'Scale factor' do
    it 'sets scale_factor to 1 by default' do
      expect(subject.scale_factor).to eq 1
    end

    it 'accepts scale_factor on creation' do
      instance = described_class.new(
        Applitools::Screenshot.from_image(::ChunkyPNG::Image.new(5, 5)), scale_factor: 3
      )
      expect(instance.instance_variable_get(:@scale_factor)).to eq 3
    end
  end

  context 'intersected region' do
    it 'returns new empty region if empty region is passed' do
      intersected_region = subject.intersected_region(
        empty_region, Applitools::Calabash::EyesCalabashScreenshot::DRIVER
      )
      expect(intersected_region.size_equals?(Applitools::Region::EMPTY)).to be true
      expect(intersected_region.x).to eq 0
      expect(intersected_region.y).to eq 0
      expect(intersected_region.object_id).to_not eq empty_region.object_id
    end

    it 'calls :convert_region_location' do
      expect(subject).to receive(:convert_region_location).with(
        non_empty_region,
        Applitools::Calabash::EyesCalabashScreenshot::DRIVER,
        Applitools::Calabash::EyesCalabashScreenshot::CONTEXT_RELATIVE
      ).and_return(non_empty_region)
      subject.intersected_region(non_empty_region, described_class::DRIVER)
    end

    it 'calls :intersect with :bounds' do
      allow(subject).to receive(:convert_region_location).and_return(non_empty_region)
      expect(non_empty_region).to receive(:intersect) do |bounds|
        expect(bounds.x).to eq 0
        expect(bounds.y).to eq 0
        expect(bounds.width).to eq 5
        expect(bounds.height).to eq 5
      end

      subject.intersected_region(non_empty_region, described_class::DRIVER)
    end
  end

  context ':sub_screenshot' do
    let(:out_of_bounds_region) { Applitools::Region.new(0, 0, 15, 5) }
    let(:clipped_region) { Applitools::Region.new(0, 0, 12, 4) }
    it_behaves_like 'responds to method', [:sub_screenshot]
    it 'throw_if_clipped' do
      allow(subject).to(
        receive(:convert_region_location).with(out_of_bounds_region, any_args).and_return(clipped_region)
      )
      expect { subject.sub_screenshot(out_of_bounds_region, described_class::DRIVER, true, false) }.to(
        raise_error Applitools::OutOfBoundsException
      )
    end
    it 'force_nil_if_clipped' do
      allow(subject).to receive(:convert_region_location).with(out_of_bounds_region, any_args).and_return(empty_region)
      expect(subject.sub_screenshot(out_of_bounds_region, described_class::DRIVER, true, true)).to be nil
    end
  end
end
