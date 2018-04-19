# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_context 'firefox settings' do
  let(:firefox_profile) { Selenium::WebDriver::Firefox::Profile.new }

  let(:opts) do
    Selenium::WebDriver::Firefox::Options.new(profile: firefox_profile).tap do |o|
      o.headless! unless ENV['SELENIUM_SERVER_URL'].casecmp('ondemand.saucelabs.com').zero?
    end
  end

  let(:caps) do
    Selenium::WebDriver::Remote::Capabilities.firefox.merge! opts.as_json
  end
end
