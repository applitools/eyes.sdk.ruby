# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength
require 'spec_helper'

RSpec.shared_examples 'Fluent API Frames' do
  let(:url_for_test) { 'https://applitools.github.io/demo/TestPages/FramesTestPage/' }

  it 'TestCheckFrame_Fully_Fluent' do
    eyes.check('Fluent - Full Frame', Applitools::Selenium::Target.frame('frame1').fully)
  end

  it 'TestCheckFrame_Fluent' do
    eyes.check('Fluent - Frame', Applitools::Selenium::Target.frame('frame1'))
  end

  it 'TestCheckFrameInFrame_Fully_Fluent' do
    eyes.check(
      'Fluent - Full Frame in Frame',
      Applitools::Selenium::Target.frame('frame1').frame('frame1-1').fully
    )
  end

  it 'TestCheckRegionInFrame_Fluent' do
    eyes.check(
      'Fluent - Region in Frame',
      Applitools::Selenium::Target.frame('frame1').region(:id, 'inner-frame-div').fully
    )
  end

  it 'TestCheckRegionInFrameInFrame_Fluent' do
    eyes.check(
      'Fluent - Region in Frame in Frame',
      Applitools::Selenium::Target.frame('frame1')
          .frame('frame1-1')
          .region(:tag_name, 'img')
          .fully
    )
  end

  it 'TestCheckRegionInFrame2_Fluent' do
    eyes.check(
      'Fluent - Inner frame div 1',
      Applitools::Selenium::Target.frame('frame1')
          .region(:id, 'inner-frame-div')
          .fully
          .timeout(5)
          .ignore(
            Applitools::Region.new(50, 50, 100, 100)
          )
    )

    eyes.check(
      'Fluent - Inner frame div 2',
      Applitools::Selenium::Target.frame('frame1')
          .region(:id, 'inner-frame-div')
          .fully
          .ignore(Applitools::Region.new(50, 50, 100, 100))
          .ignore(Applitools::Region.new(70, 170, 90, 90))
    )

    eyes.check(
      'Fluent - Inner frame div 3',
      Applitools::Selenium::Target.frame('frame1')
          .region(:id, 'inner-frame-div')
          .fully
          .timeout(5)
    )

    eyes.check(
      'Fluent - Inner frame div 4',
      Applitools::Selenium::Target.frame('frame1')
          .region(:id, 'inner-frame-div')
          .fully
    )

    eyes.check(
      'Fluent - Full frame with floating region',
      Applitools::Selenium::Target.frame('frame1')
          .fully
          .layout
          .floating(Applitools::Region.new(200, 200, 150, 150), 25, 25, 25, 25)
    )
  end

  it 'TestCheckRegionInFrame3_Fluent' do
    eyes.check(
      'Fluent - Full frame with floating region',
      Applitools::Selenium::Target.frame('frame1')
            .fully
            .layout
            .floating(Applitools::Region.new(200, 200, 150, 150), 25, 25, 25, 25)
    )
    expected_floating_regions(
      Applitools::FloatingRegion.new(
        Applitools::Region.new(200, 200, 150, 150),
        Applitools::FloatingBounds.new(25, 25, 25, 25)
      )
    )
  end

  it 'TestCheckRegionByCoordinateInFrameFully_Fluent' do
    eyes.check(
      'Fluent - Inner frame coordinates',
      Applitools::Selenium::Target.frame('frame1')
            .region(Applitools::Region.new(30, 40, 400, 1200))
            .fully
    )
  end

  it 'TestCheckFrameInFrame_Fully_Fluent2' do
    eyes.check('Fluent - Window', Applitools::Selenium::Target.window.fully)
    eyes.check(
      'Fluent - Full Frame in Frame 2',
      Applitools::Selenium::Target.frame('frame1')
            .frame('frame1-1')
            .fully
    )
  end
end
# rubocop:enable Metrics/BlockLength
