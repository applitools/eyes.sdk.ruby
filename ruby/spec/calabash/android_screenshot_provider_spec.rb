# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Applitools::Calabash::AndroidScreenshotProvider' do
  let(:subject) { Applitools::Calabash::AndroidScreenshotProvider.instance }
  let(:unknown_density_subject) { subject.with_density 333 }

  before do
    allow(Applitools::Calabash::Utils).to receive(:using_screenshot) do |_context, &block|
      block.call('spec/fixtures/pic.png')
    end

    allow(Applitools::Calabash::EyesSettings.instance).to receive(:viewport_size).and_return(width: 1, height: 1)
  end

  # it 'test' do
  #   unknown_density_subject.capture_screenshot
  # end

  it 'there are no exception if device reports unknown density' do
    expect { unknown_density_subject.capture_screenshot }.to_not raise_error
  end

  it 'logs unknown density' do
    allow(Applitools::EyesLogger).to receive(:warn) do |msg|
      expect(/^.*333.*$/).to match(msg)
    end
    unknown_density_subject.capture_screenshot
  end
end
