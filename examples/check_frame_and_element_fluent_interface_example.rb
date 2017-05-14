require 'rspec'
require 'capybara/rspec'
require_relative '../lib/eyes_selenium'
require 'applitools/capybara'

Applitools.register_capybara_driver :browser => :chrome

RSpec.describe 'Check frame and element example', :type => :feature, :js => true do
  let(:eyes) do
    Applitools::Selenium::Eyes.new.tap do |eyes|
      eyes.api_key = ENV['APPLITOOLS_API_KEY']
      eyes.force_full_page_screenshot = false
      eyes.log_handler = Logger.new(STDOUT)
      eyes.stitch_mode = :css
    end
  end

  it 'Eyes test' do
    eyes.open driver: page, app_name: 'Ruby SDK', test_name: 'Applitools frame and element example',
              viewport_size: { width: 800, height: 600 }

    visit 'https://astappev.github.io/test-html-pages/'
    target = Applitools::Selenium::Target.window.fully.ignore(:name, 'frame1')
    eyes.check('Whole page', target)
    target = target.region(eyes.driver.find_element(:id, 'overflowing-div')).fully
    eyes.check 'Overflowed region', target
    target = target.frame('frame1').fully.ignore(:id, 'inner-frame-div')
    eyes.check('', target)
    target = target.region(:id, 'inner-frame-div').fully
    eyes.check('Inner frame div', target)
    target = Applitools::Selenium::Target.window.region(:id, 'overflowing-div-image').fully.trim
    eyes.check('minions', target)
    eyes.close true
  end
end
