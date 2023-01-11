RSpec.describe '2011_bugfix_wrong_test_name' do
  context Applitools::Selenium::Configuration do
    let(:duplicate) { subject.deep_dup }
    it 'duplicate is not affected by original\'s updates' do
      subject.test_name = 'Original test name'
      expect(duplicate.test_name).to eq 'Original test name'
      subject.test_name = 'New test name'
      expect(subject.test_name).to eq 'New test name'
      expect(duplicate.test_name).to eq 'Original test name'
    end
  end
  context 'Eyes test name' do
    # class TestDriver
    #   def driver_for_eyes(eyes)
    #     Applitools::Selenium::Driver.new(eyes, driver: self, is_mobile_device: false)
    #   end
    #   def current_url
    #     'current_url'
    #   end
    #   def manage
    #     self
    #   end
    #   def window
    #     self
    #   end
    #   def size
    #     Applitools::RectangleSize.new(1024, 768)
    #   end
    # end

    let(:runner) { Applitools::Selenium::VisualGridRunner.new(1) }
    let(:eyes) { Applitools::Selenium::Eyes.new(runner: runner) }
    let(:driver) do
      Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: [:headless])
      # TestDriver.new
    end

    it 'updates test name' do
      eyes.open(app_name: 'First app name', test_name: 'First test name', driver: driver)
      eyes.configure do |c|
        expect(c.test_name).to eq('First test name')
      end
      eyes.close_async
      eyes.open(app_name: 'A second app name', test_name: 'A second test name', driver: driver)
      eyes.configure do |c|
        expect(c.test_name).to eq('A second test name')
      end
    end
    it 'updates app name' do
      eyes.open(app_name: 'First app name', test_name: 'First test name', driver: driver)
      eyes.configure do |c|
        expect(c.app_name).to eq('First app name')
      end
      eyes.close_async
      eyes.open(app_name: 'A second app name', test_name: 'A second test name', driver: driver)
      eyes.configure do |c|
        expect(c.app_name).to eq('A second app name')
      end
    end

  end
end
