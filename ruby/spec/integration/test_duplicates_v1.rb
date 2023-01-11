# frozen_string_literal: true
require 'spec_helper'

RSpec.shared_examples 'Eyes Selenium SDK - Duplicates' do
  let(:url_for_test) { 'https://applitools.github.io/demo/TestPages/VisualGridTestPage/duplicates.html' }

  it 'TestDuplicatedIFrames' do
    driver.switch_to.frame(index: 2)
    wait = Selenium::WebDriver::Wait.new(timeout: 30)
    wait.until { driver.find_element(:css, '#p2').displayed? }
    driver.switch_to.default_content
    eyes.check_window('Duplicated Iframes')
  end
end
