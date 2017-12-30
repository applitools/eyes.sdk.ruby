require 'spec_helper'

RSpec.describe Applitools::Selenium::Driver do
  subject { described_class.new Applitools::Selenium::Eyes.new, {} }
  describe 'landscape_orientation?' do
    it 'handles NameError' do
      allow(subject).to receive_message_chain(:driver, :orientation) do
        raise NameError
      end
      expect(subject.landscape_orientation?).to be false
    end
    it 'handles  Selenium::WebDriver::Error::UnknownError' do
      allow(subject).to receive_message_chain(:driver, :orientation) do
        raise Selenium::WebDriver::Error::UnknownError
      end
      expect(subject.landscape_orientation?).to be false
    end
  end
end
