# frozen_string_literal: true

Then(/^ignore status bar$/) do
  raise Applitools::EyesError, '@target is not set' unless @target
  step %(query element "view id:'statusBarBackground'")
  @target.ignore @current_element if @current_element
end

Then(/^remove status bar$/) do
  raise Applitools::EyesError, '@target is not set' unless @target
  step %(query element "view id:'statusBarBackground'")
  if @current_element
    viewport_size = Applitools::RectangleSize.from_any_argument(
      Applitools::Calabash::EyesSettings.instance.viewport_size
    )
    region_location = Applitools::Location.new(0, @current_element.size.height)
    @target.region(Applitools::Region.from_location_size(region_location, viewport_size))
  end
end

Then(/^the whole screen should match a baseline/) do
  step %(create target)
  step %(remove status bar)
  step %(target should match a baseline)
end

Then(/^query element "([^"]*)" and take (\d+)$/) do |query, index|
  @current_element = nil
  @current_element = Applitools::Calabash::Utils.get_android_element(self, query, index)
end

Then(/^check for scrollable$/) do
  unless query('ScrollView').empty?
    @present_scrollable = Applitools::Calabash::Utils.get_android_element(self, 'ScrollView', 0)
  end
end
