# frozen_string_literal: true ​
require 'logger'
require 'eyes_appium'
def android_caps
  {
      browserName: '',
      platformName: 'Android',
      platformVersion: '8.1',
      deviceName: 'Samsung Galaxy S9 WQHD GoogleAPI Emulator',
      deviceOrientation: 'portrait',
      app: 'http://saucelabs.com/example_files/ContactManager.apk',
      newCommandTimeout: 300,
      automationName: 'UiAutomator2',
      username: ENV['SAUCE_USERNAME'],
      accessKey: ENV['SAUCE_ACCESS_KEY'],
  }
end

def ios_caps
  {
      browserName: '',
      deviceName: 'iPhone XS Simulator',
      platformName: 'iOS',
      platformVersion: '12.2',
      app: 'https://applitools.bintray.com/Examples/HelloWorldiOS_1_0.zip',
      automationName: 'XCUITest',
      clearSystemFiles: true,
      noReset: true,
      NATIVE_APP: true,
      idleTimeout: 200,
      username: ENV['SAUCE_USERNAME'],
      accessKey: ENV['SAUCE_ACCESS_KEY'],
  }
end

def appium_opts
  {
      server_url: 'https://ondemand.saucelabs.com:443/wd/hub'
  }
end

eyes = Applitools::Appium::Eyes.new
eyes.log_handler = Logger.new(STDOUT)
eyes.api_key = ENV['APPLITOOLS_API_KEY']

begin
  appium_driver = Appium::Driver.new({caps: android_caps, appium_lib: appium_opts}, false)
  driver = appium_driver.start_driver
  eyes.open(app_name: 'AndroidNativeApp', test_name: 'AndroidNativeApp checkWindow', driver: driver)
  eyes.check('', Applitools::Appium::Target.window)
  eyes.close
ensure
  appium_driver.driver_quit
  eyes.abort_if_not_closed
end

begin
  appium_driver = Appium::Driver.new({caps: android_caps, appium_lib: appium_opts}, false)
  driver = appium_driver.start_driver
  eyes.open(app_name: 'AndroidNativeApp', test_name: 'AndroidNativeApp checkRegionFloating', driver: driver)
  eyes.check('', Applitools::Appium::Target.region(Applitools::Region.new(0, 100, 1400, 2000)).floating(Applitools::Region.new(10, 10, 20, 20), 3, 3, 20, 30))
  eyes.close
ensure
  appium_driver.driver_quit
  eyes.abort_if_not_closed
end

begin
  appium_driver = Appium::Driver.new({caps: ios_caps, appium_lib: appium_opts}, false)
  driver = appium_driver.start_driver
  eyes.open(app_name: 'iOSNativeApp', test_name: 'iOSNativeApp checkWindow', driver: driver)
  eyes.check('', Applitools::Appium::Target.window)
  eyes.close
ensure
  appium_driver.driver_quit
  eyes.abort_if_not_closed
end

begin
  appium_driver = Appium::Driver.new({caps: ios_caps, appium_lib: appium_opts}, false)
  driver = appium_driver.start_driver
  eyes.open(app_name: 'iOSNativeApp', test_name: 'iOSNativeApp checkRegionFloating', driver: driver)
  eyes.check('', Applitools::Appium::Target.region(Applitools::Region.new(0, 100, 375, 712)).floating(Applitools::Region.new(10, 10, 20, 20 ), 3, 3, 20, 30))
  eyes.close
ensure
  appium_driver.driver_quit
  eyes.abort_if_not_closed
end