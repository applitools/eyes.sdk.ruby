require 'eyes_appium'
RSpec.describe 'iOS basic test', appium: true do
  let(:caps) do
    {
       app: 'bs://cb07da5ba49df57efce74ce59726042108b0a61d',
       device: 'iPhone XS',
       os_version: '12',
       platformName: 'ios',
      'browserstack.appium_version': '1.17.0'
    }
  end

  it 'Appium_iOS_check_window', pending: true do
    eyes.check('Viewport Window', Applitools::Appium::Target.window)
  end

  # it 'Appium_iOS_check_region' do
  #   eyes.check('region', Applitools::Appium::Target.region(:xpath, '//*[1]'))
  # end
end