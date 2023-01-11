Applitools::EyesLogger.log_handler = Logger.new(STDOUT)
RSpec.describe 'iOS device info' do
  context 'accepts iOS device names' do
    before do
      @device_name = nil
    end
    context 'allowed' do
      after do
        expect { Applitools::Selenium::IosDeviceInfo.new(device_name: @device_name) }.to_not raise_error
      end

      it IosDeviceName::IPhone_X do
        @device_name = IosDeviceName::IPhone_X
      end
      it IosDeviceName::IPhone_11_Pro_Max do
        @device_name = IosDeviceName::IPhone_11_Pro_Max
      end
      it IosDeviceName::IPhone_12_mini do
        @device_name = IosDeviceName::IPhone_12_mini
      end
      it IosDeviceName::IPhone_12 do
        @device_name = IosDeviceName::IPhone_12
      end
      it IosDeviceName::IPhone_12_Pro do
        @device_name = IosDeviceName::IPhone_12_Pro
      end
      it IosDeviceName::IPhone_12_Pro_Max do
        @device_name = IosDeviceName::IPhone_12_Pro_Max
      end
    end
    context 'free style' do
      after do
        expect { Applitools::Selenium::IosDeviceInfo.new(device_name: @device_name) }.to raise_error Applitools::EyesIllegalArgument
      end

      it 'MyNewDevice' do
        @device_name = 'MyNewDevice'
      end
      it 'nil' do
        @device_name = nil
      end
    end
  end
  context 'accepts orientation' do
    before { @device_name = IosDeviceName::IPhone_XR }
    after do
      expect { Applitools::Selenium::IosDeviceInfo.new(device_name: @device_name, screen_orientation: @orientation) }.to_not raise_error
    end

    it 'Portrait' do
      @orientation = Orientation::PORTRAIT
    end

    it 'Landscape' do
      @orientation = Orientation::LANDSCAPE
    end

    it 'nil' do
      @orientation = nil
    end
  end

  context 'Rejects freestyle orientation' do
    before { @device_name = IosDeviceName::IPhone_XR }
    after do
      expect { Applitools::Selenium::IosDeviceInfo.new(device_name: @device_name, screen_orientation: @orientation) }.to raise_error Applitools::EyesIllegalArgument
    end

    it 'MyOrientation' do
      @orientation = 'MyOrientation'
    end

    it 'Applitools::Region' do
      @orientation = Applitools::Region::EMPTY
    end
  end

  context 'happy flow test' do
    before(:all) { @runner = Applitools::Selenium::VisualGridRunner.new(5) }
    let(:web_driver) { Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: [:headless]) }
    let(:runner) { @runner }
    let(:eyes) { Applitools::Selenium::Eyes.new(runner: runner) }
    let(:driver) { eyes.open(app_name: 'Eyes SDK Ruby', test_name: 'IosDeviceSimulationHappyFlow', driver: web_driver) }
    let(:device1) { Applitools::Selenium::IosDeviceInfo.new(device_name: IosDeviceName::IPad_Air_2) }
    let(:device2) { Applitools::Selenium::IosDeviceInfo.new(device_name: IosDeviceName::IPhone_X, screen_orientation: Orientation::LANDSCAPE) }
    before do
      eyes.configure do |c|
        c.add_browsers(device1, device2)
      end
      eyes.log_handler = Logger.new(STDOUT) unless ENV['TRAVIS']
      driver.get('http://applitools.github.io/demo')
    end

    after do
      eyes.close_async
      driver.quit
    end

    after(:all) do
      results = @runner.get_all_test_results(true)
      puts results
    end

    it '' do
      eyes.check_window
    end
  end
end