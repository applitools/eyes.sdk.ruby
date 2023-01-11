# frozen_string_literal: true

RSpec.describe Applitools::Selenium::DomCapture do
  let(:driver) { instance_double(Applitools::Selenium::Driver) }
  let(:server_connector) { Applitools::Connectivity::ServerConnector.new }
  let(:logger) { Logger.new(STDOUT) }
  let(:error) { Selenium::WebDriver::Error::NoSuchElementError }
  before do
    Applitools::EyesLogger.log_handler = logger unless ENV['TRAVIS']
  end
  it 'dom_capture handles error' do
    allow(error.class).to receive(:dump).and_raise(Applitools::EyesError, 'undefined method :dump')
    allow(driver).to receive(:execute_script).and_raise(error, 'error')
    allow(driver).to receive(:frame_chain).and_return(Applitools::Selenium::FrameChain.new)
    expect { subject.get_dom(driver, server_connector, Applitools::EyesLogger.log_handler) }.to_not raise_exception
  end
end
