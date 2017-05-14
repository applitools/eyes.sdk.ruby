require 'spec_helper'

RSpec.describe Applitools::Screenshot do
  must_have_methods = [
    :image,
    :to_blob,
    :update!
  ]

  let(:image) { ChunkyPNG::Image.new(1, 1) }
  let(:region) { Applitools::Region.new(0, 0, 10, 10) }
  let(:datastream) { image.to_datastream.to_s }

  describe 'class' do
    subject { Applitools::Screenshot }

    it 'provides method :from_image' do
      expect(subject).to respond_to :from_image
    end

    it 'provides method :from_region' do
      expect(subject).to respond_to :from_region
    end

    it 'provides method :from_datastream' do
      expect(subject).to respond_to :from_datastream
    end

    it ':from_image returns Applitools::Screenshot::Image' do
      obj = subject.from_image(image)
      expect(obj).to be_a(subject::Image)
      expect(obj).to be_a(subject)
    end

    it ':from_region returns Applitools::Screenshot::Image' do
      obj = subject.from_region(region)
      expect(obj).to be_a(subject::Image)
      expect(obj).to be_a(subject)
    end

    it ':from_datastream returns Applitools::Screenshot::Datastream' do
      obj = subject.from_datastream(datastream)
      expect(obj).to be_a(subject::Datastream)
      expect(obj).to be_a(subject)
    end

    it 'raises an exception when created directly' do
      expect { subject.new(image) }.to raise_error(Applitools::EyesError)
      expect { subject.new(datastream) }.to raise_error(Applitools::EyesError)
    end
  end

  shared_examples :updatable do
    it 'doesn\'t accept nil as an argument' do
      expect { subject.update!(nil) }.to raise_error Applitools::EyesIllegalArgument
    end
    it 'accepts only ChunkyPNG::Image' do
      expect { subject.update!('wrong') }.to raise_error Applitools::EyesIllegalArgument
      expect { subject.update!(image) }.to_not raise_error
    end
  end

  describe Applitools::Screenshot::Image do
    subject do
      Applitools::Screenshot.from_image(image)
    end
    it_should_behave_like 'responds to method', must_have_methods
    it_should_behave_like :updatable

    it 'constructor accepts only ChunkyPNG::Image' do
      expect { Applitools::Screenshot::Image.new(nil) }.to raise_error Applitools::EyesIllegalArgument
      expect { Applitools::Screenshot::Image.new(datastream) }.to raise_error Applitools::EyesIllegalArgument
      expect { Applitools::Screenshot::Image.new(image) }.to_not raise_error
    end
  end

  describe Applitools::Screenshot::Datastream do
    subject do
      Applitools::Screenshot.from_datastream(datastream)
    end
    it_should_behave_like 'responds to method', must_have_methods
    it_should_behave_like :updatable

    it 'constructor accepts only String' do
      expect { Applitools::Screenshot::Datastream.new(nil) }.to raise_error Applitools::EyesIllegalArgument
      expect { Applitools::Screenshot::Datastream.new(image) }.to raise_error Applitools::EyesIllegalArgument
      expect { Applitools::Screenshot::Datastream.new(datastream) }.to_not raise_error
    end
  end
end
