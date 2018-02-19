require 'spec_helper'

RSpec.describe Applitools::Calabash::EyesCalabashIosScreenshot do
  subject { described_class.new(Applitools::Screenshot.from_image(::ChunkyPNG::Image.new(5, 5)), scale_factor: 3) }
  let(:non_empty_region) { Applitools::Region.new(10, 11, 12, 13) }
  it_behaves_like 'responds to method', [:convert_region_location]
  context 'convert_region_location' do
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
      scaled_region = Applitools::Region.new(30, 33, 36, 39)
      expect(
        subject.convert_region_location(
          non_empty_region, described_class::DRIVER, described_class::SCREENSHOT_AS_IS
        )
      ).to match_region scaled_region
    end
    it 'from CONTEXT_RELATIVE to SCREENSHOT_AS_IS' do
      expect(
        subject.convert_region_location(
          non_empty_region, described_class::CONTEXT_RELATIVE, described_class::SCREENSHOT_AS_IS
        )
      ).to match_region non_empty_region
    end
  end
end
