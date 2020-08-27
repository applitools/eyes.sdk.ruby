require 'eyes_appium'
RSpec.describe 'Android Basic test', appium: true do
  let(:caps) do
    {
        device: 'Google Pixel 3 XL',
        platformName: 'android',
        os_version: '9.0',
        app: 'eyes_sdk_ruby_android_app',
        'browserstack.appium_version': '1.17.0'
    }
  end

  it 'Appium_Android_Pixel3XL_CheckWindow' do
    eyes.check('Window', Applitools::Appium::Target.window)
    app_output(eyes.api_key).with_raw_output do |output|
      expect(output['actualAppOutput'][0]['image']['size']).to eq('width' => 412, 'height' => 750)
    end
  end
end