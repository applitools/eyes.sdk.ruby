# frozen_string_literal: true
require 'spec_helper'

RSpec.shared_examples 'Eyes Selenium SDK - Page With Header' do
  let(:url_for_test) { 'https://applitools.github.io/demo/TestPages/PageWithHeader/index.html' }

  it 'TestCheckPageWithHeader_Window' do
    eyes.check('Page with header', Applitools::Selenium::Target.window.fully(false))
  end

  it 'TestCheckPageWithHeader_Window_Fully' do
    eyes.check('Page with header - fully', Applitools::Selenium::Target.window.fully(true))
  end

  it 'TestCheckPageWithHeader_Region' do
    eyes.check('Page with header', Applitools::Selenium::Target.region(:css, 'div.page').fully(false))
  end

  it 'TestCheckPageWithHeader_Region_Fully' do
    eyes.check('Page with header - fully', Applitools::Selenium::Target.region(:css, 'div.page').fully(true))
  end
end
