require 'spec_helper'

RSpec.shared_examples 'returns itself' do |methods|
  methods.each do |m|
    it ":#{m} returns itself" do
      expect(subject.send(m)).to be_a described_class
    end
  end
end

RSpec.describe Applitools::Images::Target do
  describe 'class' do
    it_should_behave_like 'responds to class method',
      [
        :path,
        :blob,
        :image,
        :screenshot,
        :any
      ]

    describe ':path' do
      it 'raises error for wrong path' do
        expect { described_class.path('spec/fixtures/does_not_exist.png') }.to raise_error(
          Applitools::EyesIllegalArgument
        )
      end
      it 'creates a ChunlyPNG::Image and Applitools::Screenshot' do
        expect(ChunkyPNG::Image).to receive(:from_file).with(String).and_return(ChunkyPNG::Image.new(5, 5))
        expect(Applitools::Screenshot).to receive(:new).with(ChunkyPNG::Image).and_return(
          Applitools::Screenshot.from_image(ChunkyPNG::Image.new(5, 5))
        )
        described_class.path('spec/fixtures/pic.png')
      end
      it 'creates a new Eyes::Images::Target instance' do
        expect(described_class).to receive(:new).with(Applitools::Screenshot)
        described_class.path('spec/fixtures/pic.png')
      end

      it 'returns Applitools::Images::Target instance' do
        expect(
          described_class.path('spec/fixtures/pic.png')
        ).to be_a described_class
      end
    end

    describe ':blob' do
      it 'requires an argument' do
        expect { described_class.blob(nil) }.to raise_error Applitools::EyesError
      end
      it 'requires a datastream' do
        expect { described_class.blob('invalid string') }.to raise_error ChunkyPNG::SignatureMismatch
      end
      it 'creates a new Eyes::Images::Target instance' do
        expect(described_class).to receive(:new).with(Applitools::Screenshot)
        described_class.blob(ChunkyPNG::Image.new(5, 5).to_datastream.to_blob)
      end
      it 'returns Applitools::Images::Target instance' do
        expect(
          described_class.blob(ChunkyPNG::Image.new(5, 5).to_datastream.to_blob)
        ).to be_a described_class
      end
    end

    describe ':image' do
      it 'requires an argument' do
        expect { described_class.blob(nil) }.to raise_error Applitools::EyesError
      end

      it 'creates a new Eyes::Images::Target instance' do
        expect(described_class).to receive(:new).with(Applitools::Screenshot)
        described_class.image(ChunkyPNG::Image.new(5, 5))
      end

      it 'returns Applitools::Images::Target instance' do
        expect(
          described_class.image(ChunkyPNG::Image.new(5, 5))
        ).to be_a described_class
      end
    end

    describe ':screenshot' do
      it 'requires an argument' do
        expect { described_class.blob(nil) }.to raise_error Applitools::EyesError
      end

      it 'creates a new Eyes::Images::Target instance' do
        expect(described_class).to receive(:new).with(Applitools::Screenshot)
        described_class.screenshot(Applitools::Screenshot.from_image(ChunkyPNG::Image.new(5, 5)))
      end

      it 'returns Applitools::Images::Target instance' do
        expect(
          described_class.screenshot(Applitools::Screenshot.from_image(ChunkyPNG::Image.new(5, 5)))
        ).to be_a described_class
      end
    end

    describe ':any' do
      it 'calls :screenshot for Applitools::EyesScreenshot' do
        expect(described_class).to receive(:screenshot).with(Applitools::Screenshot)
        described_class.any(Applitools::Screenshot.from_image(ChunkyPNG::Image.new(5, 5)))
      end
      it 'calls :image fro ChunkyPNG::Image' do
        expect(described_class).to receive(:image).with(ChunkyPNG::Image)
        described_class.any ChunkyPNG::Image.new(5, 5)
      end
      it 'calls :blob and :path for String' do
        expect(described_class).to receive(:blob).with(String).and_call_original
        expect(described_class).to receive(:path).with(String)
        described_class.any('doesnt_exist')
      end
      it 'raises an error for non_image argument' do
        expect { described_class.any('doesnt_exist') }.to raise_error Applitools::EyesIllegalArgument
      end
      it 'raises an error for non-image argument' do
        expect { described_class.any(0) }.to raise_error Applitools::EyesIllegalArgument
      end
    end
  end

  describe 'instance methods' do
    let(:subject) do
      described_class.image ChunkyPNG::Image.new(5, 5)
    end
    it_should_behave_like 'responds to method',
      [
        :region,
        :trim,
        :ignore,
        :image,
        :options
      ]
    it_should_behave_like 'returns itself',
      [
        :region,
        :trim,
        :ignore
      ]

    describe ':region' do
      it 'resets if nil is passed' do
        subject.region Applitools::Region::EMPTY
        expect(subject.region_to_check).to_not be nil
        subject.region
        expect(subject.region_to_check).to be nil
      end
      it 'allows only Region instance' do
        expect { subject.region('invalid region') }.to raise_error Applitools::EyesIllegalArgument
      end
    end

    describe ':ignore' do
      it 'resets if nil is passed' do
        subject.ignore Applitools::Region::EMPTY
        expect(subject.ignored_regions.empty?).to_not be true
        subject.ignore
        expect(subject.ignored_regions.empty?).to be true
      end
      it 'allows only Region instance' do
        expect { subject.region('invalid argument') }.to raise_error Applitools::EyesIllegalArgument
      end
    end

    describe ':trim' do
      it 'false by default' do
        expect(subject.options[:trim]).to be false
      end
      it 'resets if nil is passed' do
        subject.trim(nil)
      end
      it 'sets only true/false values' do
        subject.trim(0)
        expect(subject.options[:trim]).to be true
      end
      it 'true if no argument' do
        subject.trim
        expect(subject.options[:trim]).to be true
      end
    end
  end
end
