# frozen_string_literal: true
#
# UFG runner flows
#
# Call eyes.check(Target.window().fully()) - DuckDuckGo app Search Results screen
# Call eyes.check(Target.window().fully(false)) - DuckDuckGo app Search Results screen
# Call eyes.check() in Landscape
# Call eyes.check() in Portrait
# Multiple eyes.check() in one test
# Call eyes.check() through setProxy
# Call eyes.check() on Android device
# Call eyes.check() on iOS device
# Call eyes.check() on local emulator \ simulator
# Call eyes.check() on Saucelabs
# Verify IosDeviceName enum contains iPhone 8 plus and run eyes.check() with this device
# Verify IosDeviceName enum contains iPhone SE first generation and run eyes.check() with this device

require 'eyes_appium'

$batch_info ||= Applitools::BatchInfo.new
Applitools::EyesLogger.log_handler = Logger.new(STDOUT) unless ENV['TRAVIS']

RSpec.describe 'UFG runner flows' do

  let(:android_caps) do
    app = 'https://applitools.jfrog.io/artifactory/Examples/duckduckgo-5.87.0-play-debug_latest.apk'
    {
      app: app,
      deviceName: 'Google Pixel 3a XL GoogleAPI Emulator',
      platformVersion: '10.0',
      platformName: 'Android',
      clearSystemFiles: true,
      noReset: true,
      automationName: 'UiAutomator2',
      name: 'Pixel 3a xl (Ruby)',
      appiumVersion: '1.20.2',
      browserName: '',
      username: ENV['SAUCE_USERNAME'],
      accessKey: ENV['SAUCE_ACCESS_KEY'],
      appPackage: 'com.duckduckgo.mobile.android.debug',
      appActivity: 'com.duckduckgo.app.launch.Launcher',
      autoGrantPermissions: true,
    }
  end

  let(:ios_caps) do
    app = 'https://applitools.jfrog.io/artifactory/Examples/DuckDuckGo-instrumented.app.zip'
    {
      browserName: '',
      app: app,
      platformName: 'iOS',
      platformVersion: '15.4',
      processArguments: {
        args: [],
        env: {
          'DYLD_INSERT_LIBRARIES': '@executable_path/Frameworks/UFG_lib.xcframework/ios-arm64_x86_64-simulator/UFG_lib.framework/UFG_lib'
        },
      },
      username: ENV['SAUCE_USERNAME'],
      accessKey: ENV['SAUCE_ACCESS_KEY'],
    }
  end

  let(:appium_lib) { { server_url: 'https://ondemand.saucelabs.com:443/wd/hub' } }

  let(:android_sauce_driver) do
    driver = Appium::Driver.new({caps: android_caps, appium_lib: appium_lib}, false)
    driver.start_driver
    driver
  end

  let(:iphone_8_plus_sauce_driver) do
    driver = Appium::Driver.new({caps: ios_caps.merge(deviceName: 'iPhone 8 Simulator'), appium_lib: appium_lib}, false)
    driver.start_driver
    driver
  end

  let(:iphone_se_sauce_driver) do
    driver = Appium::Driver.new({caps: ios_caps.merge(deviceName: 'iPhone SE (1st generation) Simulator'), appium_lib: appium_lib}, false)
    driver.start_driver
    driver
  end

  let(:runner) { Applitools::Selenium::VisualGridRunner.new(1) }

  let(:android_portrait) {Applitools::Selenium::AndroidDeviceInfo.new(device_name: AndroidDeviceName::Pixel4XL, screen_orientation: Orientation::PORTRAIT)}
  let(:android_landscape) {Applitools::Selenium::AndroidDeviceInfo.new(device_name: AndroidDeviceName::Pixel4XL, screen_orientation: Orientation::LANDSCAPE)}
  let(:iphone_8_plus_portrait) {Applitools::Selenium::IosDeviceInfo.new(device_name: IosDeviceName::IPhone_8_Plus, screen_orientation: Orientation::PORTRAIT)}
  let(:iphone_8_plus_landscape) {Applitools::Selenium::IosDeviceInfo.new(device_name: IosDeviceName::IPhone_8_Plus, screen_orientation: Orientation::LANDSCAPE)}
  let(:iphone_se_portrait) {Applitools::Selenium::IosDeviceInfo.new(device_name: IosDeviceName::IPhone_SE, screen_orientation: Orientation::PORTRAIT)}
  let(:iphone_se_landscape) {Applitools::Selenium::IosDeviceInfo.new(device_name: IosDeviceName::IPhone_SE, screen_orientation: Orientation::LANDSCAPE)}

  let(:wait) { Selenium::WebDriver::Wait.new(timeout: 30) }

  let(:eyes) do
    eyes = Applitools::Appium::Eyes.new(runner: runner)
    eyes.configure do |conf|
      conf.api_key = ENV['APPLITOOLS_API_KEY']
      conf.save_new_tests = false
      conf.batch = $batch_info if $batch_info
      conf.app_name = 'USDK Test'
    end
    eyes
  end

  it 'Android checks' do
    # Call eyes.check(Target.window().fully()) - DuckDuckGo app Search Results screen
    # Call eyes.check(Target.window().fully(false)) - DuckDuckGo app Search Results screen
    # Call eyes.check() in Landscape
    # Call eyes.check() in Portrait
    # Multiple eyes.check() in one test
    # Call eyes.check() on Android device
    # Call eyes.check() on Saucelabs
    begin
      eyes.configure do |conf|
        conf.test_name = 'Saucelabs, Android, Multiple, Landscape, Portrait'
        conf.add_mobile_device(android_portrait)
        conf.add_mobile_device(android_landscape)
      end

      sauce_driver = android_sauce_driver

      el1 = wait.until { sauce_driver.find_element(:id, 'com.duckduckgo.mobile.android.debug:id/primaryCta') }
      el1.click
      el2 = wait.until { sauce_driver.find_element(:id, 'android:id/button2') }
      el2.click
      el3 = wait.until { sauce_driver.find_element(:id, 'com.duckduckgo.mobile.android.debug:id/omnibarTextInput') }
      el3.send_keys("Tor\n")
      sauce_driver.press_keycode(0x42)
      sleep(1) # wait for animation
      el4 = wait.until { sauce_driver.find_element(:id, 'com.duckduckgo.mobile.android.debug:id/primaryCta') }
      el4.click

      driver = eyes.open(driver: android_sauce_driver)
      eyes.check(Applitools::Selenium::Target.window)
      eyes.check(Applitools::Selenium::Target.window.fully(true))

      eyes.close(false)
    rescue
      fail 'Fail'
    ensure
      driver.quit if driver
      eyes.abort
      runner.get_all_test_results(false)
    end
  end

  it 'iOS iPhone 8 Plus checks' do
    # Call eyes.check(Target.window().fully()) - DuckDuckGo app Search Results screen
    # Call eyes.check(Target.window().fully(false)) - DuckDuckGo app Search Results screen
    # Call eyes.check() in Landscape
    # Call eyes.check() in Portrait
    # Multiple eyes.check() in one test
    # Call eyes.check() on iOS device
    # Call eyes.check() on Saucelabs
    # Verify IosDeviceName enum contains iPhone 8 plus and run eyes.check() with this device
    begin
      eyes.configure do |conf|
        conf.test_name = 'Saucelabs, iOS, iPhone 8 plus, Multiple, Landscape, Portrait'
        conf.add_mobile_device(iphone_8_plus_portrait)
        conf.add_mobile_device(iphone_8_plus_landscape)
      end

      sauce_driver = iphone_8_plus_sauce_driver

      el1 = wait.until { sauce_driver.find_element(:predicate, 'label == "Let’s Do It!" AND type == "XCUIElementTypeButton"') }
      el1.click
      el2 = wait.until { sauce_driver.find_element(:predicate, 'label == "Skip" AND type == "XCUIElementTypeButton"') }
      el2.click
      el3 = wait.until { sauce_driver.find_element(:predicate, 'name == "searchEntry"') }
      el3.send_keys("Tor\n")
      sleep(1) # wait for animation
      el4 = wait.until { sauce_driver.find_element(:predicate, 'label == "Phew!" AND name == "Phew!" AND type == "XCUIElementTypeButton"') }
      el4.click
      el5 = wait.until { sauce_driver.find_element(:xpath, "//XCUIElementTypeWebView") }

      driver = eyes.open(driver: sauce_driver)
      eyes.check(Applitools::Selenium::Target.window)
      eyes.check(Applitools::Selenium::Target.window.fully(true))

      eyes.close(false)
    rescue
      fail 'Fail'
    ensure
      driver.quit if driver
      eyes.abort
      runner.get_all_test_results(false)
    end
  end

  it 'iOS iPhone SE checks' do
    # Call eyes.check(Target.window().fully()) - DuckDuckGo app Search Results screen
    # Call eyes.check(Target.window().fully(false)) - DuckDuckGo app Search Results screen
    # Call eyes.check() in Landscape
    # Call eyes.check() in Portrait
    # Multiple eyes.check() in one test
    # Call eyes.check() on iOS device
    # Call eyes.check() on Saucelabs
    # Verify IosDeviceName enum contains iPhone SE first generation and run eyes.check() with this device
    begin
      eyes.configure do |conf|
        conf.test_name = 'Saucelabs, iOS, iPhone SE, Multiple, Landscape, Portrait'
        conf.add_mobile_device(iphone_se_portrait)
        conf.add_mobile_device(iphone_se_landscape)
      end

      sauce_driver = iphone_se_sauce_driver

      el1 = wait.until { sauce_driver.find_element(:predicate, 'label == "Let’s Do It!" AND type == "XCUIElementTypeButton"') }
      el1.click
      el2 = wait.until { sauce_driver.find_element(:predicate, 'label == "Skip" AND type == "XCUIElementTypeButton"') }
      el2.click
      el3 = wait.until { sauce_driver.find_element(:predicate, 'name == "searchEntry"') }
      el3.send_keys("Tor\n")
      sleep(1) # wait for animation
      el4 = wait.until { sauce_driver.find_element(:predicate, 'label == "Phew!" AND name == "Phew!" AND type == "XCUIElementTypeButton"') }
      el4.click
      el5 = wait.until { sauce_driver.find_element(:xpath, "//XCUIElementTypeWebView") }

      driver = eyes.open(driver: sauce_driver)
      eyes.check(Applitools::Selenium::Target.window)
      eyes.check(Applitools::Selenium::Target.window.fully(true))
      eyes.close(false)
    rescue
      fail 'Fail'
    ensure
      driver.quit if driver
      eyes.abort
      runner.get_all_test_results(false)
    end
  end

  it 'Call eyes.check() through setProxy', skip: true do
    conf.set_proxy('http://localhost:8000')
  end

  it 'Call eyes.check() on local emulator \ simulator', skip: true do

  end

end
