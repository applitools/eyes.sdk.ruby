require 'spec_helper'

RSpec.describe Applitools::Calabash::Eyes do
  context 'Screenshot class' do
    it 'respects EnvironmentDetector.current_environment' do
      allow_any_instance_of(Applitools::Calabash::EnvironmentDetector).to(
        receive(:current_environment).and_return(:android)
      )
      expect(subject.screenshot_provider).to be_a(Applitools::Calabash::AndroidScreenshotProvider)
      allow_any_instance_of(Applitools::Calabash::EnvironmentDetector).to receive(:current_environment).and_return :ios
      expect(subject.screenshot_provider).to be_a(Applitools::Calabash::IosScreenshotProvider)
    end
  end
  context do
    before do
      allow(Applitools::Calabash::Utils).to receive(:using_screenshot).and_yield('spec/fixtures/pic.png')
      subject.density = 234
    end
    context 'iOS' do
      # before do
      #   allow_any_instance_of(Applitools::Calabash::EnvironmentDetector).to receive(:current_environment).and_return :ios
      # end
      # it 'passes :scale_factor for a screenshot' do
      #   expect(Applitools::Calabash::EyesCalabashAndroidScreenshot).to receive(:new).with(kind_of(Applitools::Screenshot), scale_factor: 234)
      #   subject.capture_screenshot
      # end
    end
    context 'Android' do
      # before do
      #   allow_any_instance_of(Applitools::Calabash::EnvironmentDetector).to receive(:current_environment).and_return :android
      # end
      # it 'passes :density for a screenshot' do
      #   expect(Applitools::Calabash::EyesCalabashAndroidScreenshot).to receive(:new).with(kind_of(Applitools::Screenshot), density: 234)
      #   subject.capture_screenshot
      # end
    end
  end
  context ':region_for_element' do
    let(:calabash_element) { Applitools::Calabash::Element.new }
    # let(:region) {  }
    xit 'Accepts Applitools::Calabash::CalabashElement' do
      expect { subject.send(:region_for_element) }
    end
    it 'Accepts Applitools::Region'
    it 'Rejects unknown argument'
  end
end
