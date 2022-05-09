# frozen_string_literal: true

require 'eyes_selenium'
require 'eyes_images'
require 'eyes_calabash'
require 'eyes_capybara'
require 'uri'
require 'net/http'
require 'webdrivers'
require 'test_utils'
require 'test_utils/selenium_workaround'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.formatter = :documentation

  config.before mock_connection: true do
    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:start_session) do
      Applitools::Session.new('dummy_id', 'dummy_url')
    end

    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:stop_session) do
      Applitools::TestResults.new
    end

    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:match_window) do
      true
    end

    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:put_dom).and_return('https://dom.location.url')
    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:put_screenshot).and_return('https://screenshot.location.url')
    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:rendering_info).and_return({})
    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:close_batch).with(any_args)

  end

  config.before clear_environment: true do
    Applitools::Helpers.instance_variable_set :@environment_variables, {}
  end

end
