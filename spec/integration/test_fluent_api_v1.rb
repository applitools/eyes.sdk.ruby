# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength
require 'spec_helper'

RSpec.shared_examples 'Fluent API' do
  let(:url_for_test) { 'https://applitools.github.io/demo/TestPages/FramesTestPage/' }

  it('TestCheckRegionWithIgnoreRegion_Fluent') do
    target = Applitools::Selenium::Target.region(
      :id, 'overflowing-div'
    ).ignore(Applitools::Region.new(50, 50, 100, 100))
    eyes.check('Fluent - Region with Ignore region', target)
  end

  it('TestCheckRegionBySelectorAfterManualScroll_Fluent') do
    driver.execute_script('window.scrollBy(0,900)')
    target = Applitools::Selenium::Target.region(:id, 'centered')
    eyes.check('Fluent - Region by selector after manual scroll', target)
  end

  it('TestCheckWindow_Fluent') do
    eyes.check('Fluent - Window', Applitools::Selenium::Target.window)
  end

  it('TestCheckWindowWithIgnoreBySelector_Centered_Fluent') do
    eyes.check(
      'Fluent - Window with ignore region by selector centered',
      Applitools::Selenium::Target.window.ignore(:id, 'centered')
    )
  end

  it('TestCheckWindowWithIgnoreBySelector_Stretched_Fluent') do
    eyes.check(
      'Fluent - Window with ignore region by selector centered',
      Applitools::Selenium::Target.window.ignore(:id, 'stretched')
    )
  end

  it('TestCheckWindowWithFloatingBySelector_Fluent') do
    eyes.check(
      'Fluent - Window with ignore region by selector',
      Applitools::Selenium::Target.window.floating(
        :id, 'overflowing-div', 3, 3, 20, 30
      )
    )
  end

  it('TestCheckRegionByCoordinates_Fluent') do
    eyes.check(
      'Fluent - Region by coordinates',
      Applitools::Selenium::Target.region(
        Applitools::Region.new(
          50, 70, 90, 110
        )
      )
    )
  end

  it('TestCheckOverflowingRegionByCoordinates_Fluent') do
    eyes.check(
      'Fluent - Region by overflowing coordinates',
      Applitools::Selenium::Target.region(
        Applitools::Region.new(50, 110, 90, 550)
      )
    )
  end

  it('TestCheckElementWithIgnoreRegionByElementOutsideTheViewport_Fluent') do
    element = driver.find_element(:id, 'overflowing-div-image')
    ignore_region = driver.find_element(:id, 'overflowing-div')

    eyes.check('Fluent - Region by element', Applitools::Selenium::Target.region(element).ignore(ignore_region))
  end

  it('TestCheckElementWithIgnoreRegionBySameElement_Fluent') do
    element = driver.find_element(:id, 'overflowing-div-image')
    eyes.check('Fluent - Region by element', Applitools::Selenium::Target.region(element).ignore(element))
    app_output(eyes.api_key).with_ignore_regions do |actual_ignore_regions|
      expect(actual_ignore_regions).to(
        include(Applitools::Region.new(0, 0, 304, 184))
      )
    end
  end

  it('TestCheckFullWindowWithMultipleIgnoreRegionsBySelector_Fluent') do
    eyes.check('Fluent - Region by element', Applitools::Selenium::Target.window.fully.ignore(:css, '.ignore'))
    app_output(eyes.api_key).with_ignore_regions do |actual_ignore_regions|
      expect(actual_ignore_regions).to include(Applitools::Region.new(122, 928, 456, 306))
      expect(actual_ignore_regions).to include(Applitools::Region.new(8, 1270, 690, 206))
      expect(actual_ignore_regions).to include(Applitools::Region.new(10, 284, 800, 500))
    end
  end

  it('TestScrollbarsHiddenAndReturned_Fluent') do
    eyes.check('Fluent - Window (Before)', Applitools::Selenium::Target.window.fully)
    eyes.check(
      'Fluent - Inner frame div',
      Applitools::Selenium::Target.frame('frame1').region(:id, 'inner-frame-div').fully
    )
    eyes.check('Fluent - Window (After)', Applitools::Selenium::Target.window.fully)
  end

  it('TestCheckElementFully_Fluent') do
    element = driver.find_element(:id, 'overflowing-div-image')
    eyes.check('Fluent - Region by element - fully', Applitools::Selenium::Target.region(element).fully)
  end

  it('TestSimpleRegion') do
    eyes.check(nil, Applitools::Selenium::Target.region(Applitools::Region.new(50, 50, 100, 100)))
  end

  it('TestIgnoreDisplacements') do
    eyes.check(
      'Fluent - Ignore Displacements = true',
      Applitools::Selenium::Target.window.ignore_displacements(true).fully
    )
    expected_property('ignoreDisplacements', true)
  end

  it('TestIgnoreDisplacements') do
    eyes.check(
      'Fluent - Ignore Displacements = false',
      Applitools::Selenium::Target.window.ignore_displacements(false).fully
    )
    expected_property('ignoreDisplacements', false)
  end

  it('TestCheckWindowWithIgnoreRegion_Fluent') do
    driver.find_element(:tag_name, 'input').send_keys('My Input')
    eyes.check(
      'Fluent - Window with Ignore region',
      Applitools::Selenium::Target.window
        .fully
        .timeout(5)
        .ignore_caret
        .ignore(Applitools::Region.new(50, 50, 100, 100))
    )
    app_output(eyes.api_key).with_ignore_regions do |actual_ignore_regions|
      expect(actual_ignore_regions).to include(Applitools::Region.new(50, 50, 100, 100))
    end

  end

  it('TestCheckWindowWithIgnoreBySelector_Fluent') do
    eyes.check(
      'Fluent - Window with ignore region by selector',
      Applitools::Selenium::Target.window.ignore(:id, 'overflowing-div')
    )
    app_output(eyes.api_key).with_ignore_regions do |actual_ignore_regions|
      expect(actual_ignore_regions).to include(Applitools::Region.new(7, 79, 306, 186))
    end
  end

  it('TestCheckWindowWithFloatingByRegion_Fluent') do
    eyes.check(
      'Fluent - Window with floating region by region',
      Applitools::Selenium::Target.window.floating(
        Applitools::FloatingRegion.new(
          Applitools::Region.new(10, 10, 20, 20),
          Applitools::FloatingBounds.new(4, 4, 21, 31)
        )
      )
    )
    app_output(eyes.api_key).with_floating_regions do |actual_floating_regions|
      expect(actual_floating_regions).to include(Applitools::FloatingRegion.new(10, 10, 20, 20, 5, 5, 22, 32))
    end
  end
end
# rubocop:enable Metrics/BlockLength
