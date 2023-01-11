require 'eyes_appium'
RSpec.describe 'Android Basic test', appium: true do
  let(:caps) do
    {
      device: 'Google Pixel 3',
      platformName: 'android',
      os_version: '9.0',
      app: 'eyes_sdk_ruby_android_app',
      'browserstack.appium_version': '1.17.0'
    }
  end

  let(:button) { driver.find_element(:class_name, 'android.widget.Button') }
  let(:label_in_container) { driver.find_element(:uiautomator, 'new UiSelector().textContains("You successfully clicked the button!")') }
  it 'Appium_Android_CheckWindow', pending: true do
    eyes.check('Window', Applitools::Appium::Target.window.ignore(button))
    app_output(eyes.api_key).with_ignore_regions do |actual_ignore_regions|
      expect(actual_ignore_regions).to include(Applitools::Region.new(151, 237, 90, 48))
    end
  end
  it 'Appium_Android_CheckRegionWithIgnoreRegion', pending: true do
    button.click
    eyes.check(
      'Image Container',
      Applitools::Appium::Target.region(:id, 'com.applitools.helloworld.android:id/image_container').
          ignore(label_in_container).
          ignore(id: 'com.applitools.helloworld.android:id/image')
    )
    app_output(eyes.api_key).with_ignore_regions do |actual_ignore_regions|
      fail
    end
  end
  it 'Appium_Android_CheckRegion', pending: true do
    eyes.check('Button', Applitools::Appium::Target.region(button))
  end

end