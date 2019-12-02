# frozen_string_literal: true
require 'spec_helper'

RSpec.shared_examples 'Eyes Selenium SDK - Special Cases' do
  let(:url_for_test) { 'http://applitools.github.io/demo/TestPages/WixLikeTestPage/index.html' }

  it 'TestCheckRegionInAVeryBigFrame' do
    eyes.check('map', Applitools::Selenium::Target.frame('frame1').region(:tag_name, 'img'))
  end

  it 'TestCheckRegionInAVeryBigFrameAfterManualSwitchToFrame' do
    driver.switch_to.frame('frame1')
    eyes.check('', Applitools::Selenium::Target.region(:css, 'img'))
  end
end
