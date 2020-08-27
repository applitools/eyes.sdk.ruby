require 'eyes_appium'
RSpec.describe 'iOS basic test', appium: true do
  let(:caps) do
    {
       app: 'eyes_sdk_ruby_ios_app',
       device: 'iPhone XS',
       os_version: '12',
       platformName: 'ios',
       'browserstack.appium_version': '1.17.0'
    }
  end

  let(:button) { driver.find_element(:predicate, 'type == \'XCUIElementTypeButton\'') }


  it 'Appium_iOS_check_window' do
    eyes.check('Viewport Window', Applitools::Appium::Target.window.ignore(button))
  end

  # it 'Appium_iOS_check_region' do
  #   eyes.check('region', Applitools::Appium::Target.region(:xpath, '//*[1]'))
  # end
end