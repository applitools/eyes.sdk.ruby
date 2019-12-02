# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Selenium' do
  before(:each) { eyes.accessibility_validation = Applitools::AccessibilityLevel::AAA }

  describe 'Accessibility', selenium: true do
    let(:url_for_test) { 'https://applitools.github.io/demo/TestPages/FramesTestPage/' }
    let(:target) do
      Applitools::Selenium::Target.window.accessibility(
        :css, '.ignore',
        type: Applitools::AccessibilityRegionType::GRAPHICAL_OBJECT
      )
    end

    it 'TestAccessibilityRegions' do
      eyes.check('step1', target)
      expected_property('accessibilityLevel', Applitools::AccessibilityLevel::AAA)
      expected_accessibility_regions(
        Applitools::AccessibilityRegion.new(
          Applitools::Region.new(10, 284, 800, 500),
          Applitools::AccessibilityRegionType::GRAPHICAL_OBJECT
        ),
        Applitools::AccessibilityRegion.new(
          Applitools::Region.new(8, 1270, 675, 206),
          Applitools::AccessibilityRegionType::GRAPHICAL_OBJECT
        ),
        Applitools::AccessibilityRegion.new(
          Applitools::Region.new(115, 928, 456, 306),
          Applitools::AccessibilityRegionType::GRAPHICAL_OBJECT
        )
      )
    end
  end
end
