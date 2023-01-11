# frozen_string_literal: true

require 'eyes_selenium'
RSpec.describe Applitools::ImageMatchSettings do
  it 'default value' do
    expect(subject.json_data).to include(
      MatchLevel: 'Strict',
      SplitTopHeight: 0,
      SplitBottomHeight: 0,
      IgnoreCaret: true,
      IgnoreDisplacements: false,
      Accessibility: [],
      Ignore: [],
      Layout: [],
      Floating: [],
      Strict: [],
      Content: [],
      Exact: {
        MinDiffIntensity: 0,
        MinDiffWidth: 0,
        MinDiffHeight: 0,
        MatchThreshold: 0
      },
      scale: 0,
      remainder: 0,
      EnablePatterns: false,
      UseDom: false
    )
  end
end

RSpec.describe Applitools::MatchWindowData, skip: true do
  subject { Applitools::MatchWindowData.new(default_image_match_settings) }
  let(:default_image_match_settings) { Applitools::ImageMatchSettings.new }
  let(:result_match_settings) { subject.to_hash['Options']['ImageMatchSettings'] }
  let(:expected_image_match_settings) { default_image_match_settings.json_data }
  it 'default value' do
    expect(subject.to_hash['Options']['ImageMatchSettings']).to include(default_image_match_settings.json_data)
  end
  context 'merge values' do
    it 'use_dom' do
      target = Applitools::Selenium::Target.window.use_dom
      subject.read_target(target, nil)
      expected_image_match_settings[:UseDom] = true
      expect(result_match_settings).to include(expected_image_match_settings)
    end

    it 'enable_patterns' do
      target = Applitools::Selenium::Target.window.enable_patterns
      subject.read_target(target, nil)
      expected_image_match_settings[:EnablePatterns] = true
      expect(result_match_settings).to include(expected_image_match_settings)
    end

    it 'ignore_displacements' do
      target = Applitools::Selenium::Target.window.ignore_displacements
      subject.read_target(target, nil)
      expected_image_match_settings[:IgnoreDisplacements] = true
      expect(result_match_settings).to include(expected_image_match_settings)
    end

    it 'match_level :exact' do
      target = Applitools::Selenium::Target.window.match_level(
        Applitools::MatchLevel::EXACT,
        min_diff_intensity: 10
      )
      subject.read_target(target, nil)
      expected_image_match_settings[:MatchLevel] = Applitools::MatchLevel::EXACT
      expected_image_match_settings[:Exact][:MinDiffIntensity] = 10
      expect(result_match_settings).to include(expected_image_match_settings)
    end

    it 'match_level :layout' do
      target = Applitools::Selenium::Target.window.match_level(Applitools::MatchLevel::LAYOUT)
      subject.read_target(target, nil)
      expected_image_match_settings[:MatchLevel] = Applitools::MatchLevel::LAYOUT
      expect(result_match_settings).to include(expected_image_match_settings)
    end

    it 'ignore regions', pending: true do
      region = Applitools::Region.new(10, 10, 20, 20)
      target = Applitools::Selenium::Target.window.ignore(region)
      subject.app_output = Applitools::AppOutputWithScreenshot.new(
        Applitools::AppOutput.new(nil, nil),
        Applitools::Selenium::FullpageScreenshot.new(
          Applitools::Screenshot.from_any_image(ChunkyPNG::Image.new(5, 5)),
          region_provider: Applitools::Selenium::RegionProvider.new(nil, Applitools::Region::EMPTY)
        ),
        false
      )
      subject.read_target(target, nil)
      subject.convert_ignored_regions_coordinates
      expect(result_match_settings[:Ignore]).to include(region.to_hash)
    end
  end
end

RSpec.shared_examples 'pass property to image match settings' do |property, value, ms_property = property|
  it "#{property}_getter" do
    default_match_settings = Applitools::ImageMatchSettings.new
    expect(subject.send(property)).to eq default_match_settings.send(ms_property)
  end

  it property do
    expect(subject.default_match_settings.send(ms_property)).to_not eq(value)
    subject.send("#{property}=", value)
    expect(subject.default_match_settings.send(ms_property)).to eq(value)
  end
end

RSpec.describe Applitools::Selenium::Configuration do
  it_should_behave_like 'pass property to image match settings', :scale, 5
  it_should_behave_like 'pass property to image match settings', :remainder, 5
  it_should_behave_like 'pass property to image match settings', :match_level, Applitools::MatchLevel::LAYOUT2
  it_should_behave_like(
    'pass property to image match settings',
    :accessibility_validation,
    Applitools::AccessibilitySettings.new(Applitools::AccessibilityLevel::AA, Applitools::AccessibilityGuidelinesVersion::WCAG_2_0),
    :accessibility_settings
  )
  it_should_behave_like(
    'pass property to image match settings',
    :exact,
    Applitools::ImageMatchSettings::Exact.new.tap do |e|
      e.min_diff_intensity = 5
      e.min_diff_height = 6
    end
  )
end
