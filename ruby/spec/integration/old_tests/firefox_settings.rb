# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_context 'firefox settings' do
  let(:firefox_profile) { Selenium::WebDriver::Firefox::Profile.new }

  let(:args) do
    [].tap do |args|
      args << '-headless' unless ENV['SELENIUM_SERVER_URL'].casecmp('ondemand.saucelabs.com').zero?
    end
  end

  let(:opts) do
    {
      'moz:firefoxOptions' => {
        profile: firefox_profile.as_json['zip'],
        args: args
      }
    }
  end

  let(:caps) do
    Selenium::WebDriver::Remote::Capabilities.firefox.merge! opts
  end
end
