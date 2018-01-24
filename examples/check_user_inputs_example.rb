require 'rspec'
require 'capybara/rspec'
require_relative '../lib/eyes_selenium'
require 'applitools/capybara'

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

Applitools.register_capybara_driver :browser => :chrome

RSpec.describe 'Check frame and element example', :type => :feature, :js => true do
  let(:eyes) do
    Applitools::Selenium::Eyes.new.tap do |eyes|
      eyes.api_key = ENV['APPLITOOLS_API_KEY']
      eyes.force_full_page_screenshot = false
      eyes.log_handler = Logger.new(STDOUT)
      eyes.stitch_mode = :css
      # eyes.match_level = Applitools::MATCH_LEVEL[:content]
      # eyes.proxy = Applitools::Connectivity::Proxy.new 'http://localhost:9999'
    end
  end

  it 'Eyes test' do
    eyes.open driver: page, app_name: 'Ruby SDK user controls', test_name: 'Applitools frame and element example',
              viewport_size: { width: 800, height: 600 }

    visit 'https://astappev.github.io/test-html-pages/'
    page.execute_script("window.scrollTo(0, 25);")
    target = Applitools::Selenium::Target.window.fully.ignore(
        Applitools::Region.new(55, 60, 90, 90), Applitools::PaddingBounds.new(10, 12, 14, 16)
    ).ignore(:id, 'overflowing-div-image')
    eyes.check('Whole page', target)
    page.find(:id, 'overflowing-div').click
    page.find(:id, 'overflowing-div-image').click
    page.find(:css, 'input[ng-model="user.name"]').set('test1')
    page.find(:css, 'input[ng-model="user.email"').set('test2')

    target = Applitools::Selenium::Target.window.ignore(
        Applitools::Region.new(55, 60, 90, 90), Applitools::PaddingBounds.new(10, 12, 14, 16)
    ).ignore(:id, 'overflowing-div-image')
    eyes.check('Whole page', target)
    page.find(:id, 'overflowing-div').click
    page.find(:id, 'overflowing-div-image').click
    page.find(:css, 'input[ng-model="user.name"]').set('test3')
    page.find(:css, 'input[ng-model="user.email"').set('test4')

    target = Applitools::Selenium::Target.window.region(:id, 'overflowing-div')
    eyes.check('A region', target)
    page.find(:id, 'overflowing-div').click

    target = Applitools::Selenium::Target.region(eyes.driver.find_element(:id, 'overflowing-div')).fully
    eyes.check 'Overflowed region', target
    page.find(:id, 'overflowing-div').click
    target = Applitools::Selenium::Target.window.frame('frame1').fully.floating(
        :id, 'inner-frame-div', 10, 10, 10, 10, Applitools::PaddingBounds.new(10, 12, 14, 16)
    )
    eyes.check('', target)

    within_frame(name: 'frame1') do
      page.find(:id, 'inner-frame-div').click
    end
    within_frame(name: 'frame1') do
      target = Applitools::Selenium::Target.window.region(:id, 'inner-frame-div').fully.match_level(:exact) # Region in frame..
      eyes.check('Inner frame div', target)

      page.find(:id, 'inner-frame-div').click
    end

    target = Applitools::Selenium::Target.window.region(:id, 'overflowing-div-image').fully.floating(Applitools::Region.new(0,0,30,30), 10,10,10,10)
    eyes.check('minions', target)
    eyes.close true
  end
end
