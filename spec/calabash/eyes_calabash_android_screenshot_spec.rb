require 'spec_helper'

RSpec.describe Applitools::Calabash::EyesCalabashAndroidScreenshot do
  it 'Android densities table' do
    expect(described_class::ANDROID_DENSITY.keys).to contain_exactly(120, 160, 213, 240, 320, 480)
    expect(described_class::ANDROID_DENSITY).to include(
      120 => 0.75,
      160 => 1,
      213 => 1.33,
      240 => 1.5,
      320 => 2,
      480 => 3
    )
  end

  describe 'density & scale_factor' do
    # subject { described_class.new(Applitools::Screenshot.from_image(::ChunkyPNG::Image.new(5, 5)), scale_factor: 3) }
    it 'sets scale_factor to 1 by default' do
      new_instance = described_class.new(Applitools::Screenshot.from_image(::ChunkyPNG::Image.new(5, 5)))
      expect(new_instance.scale_factor).to eq 1
    end

    it 'sets scale_factor from options' do
      new_instance = described_class.new(
        Applitools::Screenshot.from_image(::ChunkyPNG::Image.new(5, 5)), scale_factor: 1.5
      )
      expect(new_instance.scale_factor).to eq 1.5
    end

    it 'rejects invalid density' do
      expect do
        described_class.new(Applitools::Screenshot.from_image(::ChunkyPNG::Image.new(5, 5)), density: 242)
      end.to raise_error Applitools::EyesError
    end

    it 'converts density to scale factor' do
      new_instance = described_class.new(Applitools::Screenshot.from_image(::ChunkyPNG::Image.new(5, 5)), density: 240)
      expect(new_instance.scale_factor).to eq 1.5
    end
  end

  describe 'convert_region_location' do
    subject { described_class.new(Applitools::Screenshot.from_image(::ChunkyPNG::Image.new(5, 5)), scale_factor: 3) }
    let(:non_empty_region) { Applitools::Region.new(10, 11, 12, 13) }
    let(:scaled_region) { non_empty_region.scale_it!(1.to_f / 3) }

    it { expect(subject).to respond_to :convert_region_location }

    context 'raises exception' do
      it 'DRIVER except SCREENSHOT_AS_IS' do
        expect { subject.convert_region_location(Applitools::Region::EMPTY, described_class::DRIVER, :OTHER) }.to(
          raise_error Applitools::EyesError
        )
      end
      it 'CONTEXT_RELATIVE except SCREENSHOT_AS_IS' do
        expect do
          subject.convert_region_location(Applitools::Region::EMPTY, described_class::CONTEXT_RELATIVE, :OTHER)
        end.to(
          raise_error Applitools::EyesError
        )
      end
      it 'any other FROM' do
        expect { subject.convert_region_location(Applitools::Region::EMPTY, :OTHER, :OTHER) }.to(
          raise_error Applitools::EyesError
        )
      end
    end

    it 'from DRIVER to SCREENSHOT_AS_IS' do
      expect(
        subject.convert_region_location(
          non_empty_region, described_class::DRIVER, described_class::SCREENSHOT_AS_IS
        )
      ).to match_region(non_empty_region)
    end

    it 'from CONTEXT_RELATIVE to SCREENSHOT_AS_IS' do
      expect(non_empty_region).to receive(:scale_it!).with(1.to_f / 3).at_least(:once).and_call_original
      expect(
        subject.convert_region_location(
          non_empty_region, described_class::CONTEXT_RELATIVE, described_class::SCREENSHOT_AS_IS
        )
      ).to match_region(scaled_region)
    end
  end
end
