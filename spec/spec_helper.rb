# frozen_string_literal: true

require 'eyes_selenium'
require 'eyes_images'
require 'eyes_calabash'
require 'eyes_capybara'
require 'uri'
require 'net/http'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.before mock_connection: true do
    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:start_session) do
      Applitools::Session.new('dummy_id', 'dummy_url', true)
    end

    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:stop_session) do
      Applitools::TestResults.new
    end

    allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:match_window) do
      true
    end
  end

  config.before clear_environment: true do
    Applitools::Helpers.instance_variable_set :@environment_variables, {}
  end

  config.include_context 'selenium workaround', selenium: true
  config.include_context 'selenium workaround', visual_grid: true
end
