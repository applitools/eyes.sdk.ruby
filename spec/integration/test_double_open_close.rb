require 'spec_helper'

RSpec.shared_examples 'Eyes Selenium SDK - Visual Grid TestDoubleOpenClose' do
  let(:url_for_test) { 'https://applitools.github.io/demo/TestPages/VisualGridTestPage/' }
  it 'TestDoubleOpenCheckClose' do
    web_driver.get(url_for_test)
    eyes.open(driver: web_driver, app_name: 'Applitools Eyes Ruby SDK', test_name: (['TestDoubleOpenCheckClose'] + test_name_modifiers).join('_'))
  end
end