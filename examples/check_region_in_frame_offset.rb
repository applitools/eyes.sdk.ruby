# frozen_string_literal: true

require 'rspec'
require 'capybara/rspec'
require_relative '../lib/eyes_selenium'
require 'applitools/capybara'

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

Applitools.register_capybara_driver :browser => :chrome

RSpec.describe 'Check region in frame offset example', :type => :feature, :js => true do
  let(:eyes) do
    Applitools::Selenium::Eyes.new.tap do |eyes|
      eyes.api_key = ENV['APPLITOOLS_API_KEY']
      eyes.force_full_page_screenshot = true
      eyes.log_handler = Logger.new(STDOUT)
      eyes.stitch_mode = :css
      eyes.hide_scrollbars = false
      eyes.debug_screenshot = false
      # eyes.match_level = Applitools::MATCH_LEVEL[:content]
      # eyes.proxy = Applitools::Connectivity::Proxy.new 'http://localhost:9999'
    end
  end

  it 'Eyes test' do
    eyes.open driver: page, app_name: 'Eyes Selenium SDK', test_name: 'WIX like test',
              viewport_size: { width: 450, height: 600 }

    visit 'http://applitools.github.io/demo/TestPages/WixLikeTestPage/index.html'

    eyes.check('map-3', Applitools::Selenium::Target.window)
    eyes.check('map-2', Applitools::Selenium::Target.window.fully)
    eyes.check('map-1', Applitools::Selenium::Target.frame('frame1'))

    target = Applitools::Selenium::Target.frame('frame1').region(tag_name: 'img')
    eyes.check('map', target)
    eyes.close true
  end
end
