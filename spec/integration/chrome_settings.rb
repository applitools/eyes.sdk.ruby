# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_context 'chrome settings' do
  let(:opts) do
    chrome_opts = Selenium::WebDriver::Chrome::Options.new.tap do |o|
      o.add_argument('headless') unless ENV['SELENIUM_SERVER_URL'].casecmp('ondemand.saucelabs.com').zero?
      o.add_argument('disable-infobars')
    end
    { 'chromeOptions' => chrome_opts.as_json }
  end

  let(:caps) do
    Selenium::WebDriver::Remote::Capabilities.chrome.merge! opts
  end
end
