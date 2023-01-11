RSpec.describe 'Convert Region Coordinates' do
  context 'Updates target' do
    let(:web_driver) { Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: [:headless]) }
    let(:eyes) { Applitools::Selenium::Eyes.new(runner: runner) }
    let(:runner) { Applitools::Selenium::VisualGridRunner.new(5) }
    let(:driver) { eyes.open(app_name: 'MyAppName', test_name: 'MyTestName', driver: web_driver, viewport_size: {width: 800, height: 550}) }
    let(:target_non_selector) { Applitools::Selenium::Target.window }
    let(:target_selector) { Applitools::Selenium::Target.region(:css, 'div#overflowing-div') }
    it 'full-page mode' do
      expect_any_instance_of(Applitools::Selenium::Target).to_not receive(:convert_coordinates)
      driver.get('https://applitools.github.io/demo/TestPages/SimpleTestPage/')
      eyes.check('Stepo0', target_non_selector)
    end
    it 'selector mode', mock_connection: true, skip: true do
      expect_any_instance_of(Applitools::Selenium::Target).to receive(:convert_coordinates)
      driver.get('https://applitools.github.io/demo/TestPages/SimpleTestPage/')
      eyes.check('Stepo0', target_selector)
    end
  end
  context 'Translate coordinates' do
    let(:selector_regions) do
      [
        {'x' => 10, 'y' => 10, 'width' => 10, 'height' => 10},
        {'x' => 5, 'y' => 5, 'width' => 100, 'height' => 200}
      ]
    end
    let(:region_to_translate) { Applitools::Region.new(8,9,10,11) }
    it 'function' do
      Applitools::Selenium::VgMatchWindowData::CONVERT_COORDINATES.call(region_to_translate, selector_regions)
      expect(region_to_translate.width).to eq 10
      expect(region_to_translate.height).to eq 11
      expect(region_to_translate.top).to eq 4
      expect(region_to_translate.left).to eq 3
    end
  end
end