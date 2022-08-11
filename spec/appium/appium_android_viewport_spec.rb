# frozen_string_literal: true

require 'eyes_appium'

RSpec.describe 'Android viewport test', appium: true do
  let(:caps) do
    {
      deviceName: 'Google Pixel 3 XL',
      platformName: 'android',
      os_version: '9.0',
      app: 'app_android',
      'browserstack.appium_version': '1.19.1'
    }
  end

  let(:button) { driver.find_element(:uiautomator, 'new UiSelector().textContains("Scrollview footer header activity")') }

  it 'Appium_Android_CheckCaptureElementOverlay' do
    button.click
    eyes.check('Capture Element Overlay', Applitools::Appium::Target.window())
  end

end
