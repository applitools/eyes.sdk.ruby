# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Applitools::Calabash::FullPageCaptureAlgorithm::CalabashAndroidScreenshot', skip: true do
  let(:dummy_class) do
    class Dummy
      include Applitools::Calabash::FullPageCaptureAlgorithm::CalabashAndroidScreenshot
    end
  end
  let(:subject) { dummy_class.new }
  let(:image) { ChunkyPNG::Image.from_file('spec/fixtures/pic.png') }
  let(:screenshot) { Applitools::Screenshot.from_image(image) }
  let(:unknown_density) { 333 }
  before do
    allow(subject).to receive(:logger).and_return(Applitools::EyesLogger)
  end

  it 'there are no exception when unknown density is passed' do
    expect { subject.calabash_android_screenshot(screenshot, unknown_density) }.to_not raise_error
  end

  it 'reports unknown density' do
    expect(Applitools::EyesLogger).to receive(:warn) do |msg|
      expect(/^.*#{unknown_density}.*$/).to match(msg)
    end
    subject.calabash_android_screenshot(screenshot, unknown_density)
  end
end
