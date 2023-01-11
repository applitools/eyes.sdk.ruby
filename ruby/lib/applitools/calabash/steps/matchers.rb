# frozen_string_literal: true

Then(/^create target$/) do
  @target = nil
  @target = Applitools::Calabash::Target.new
end

Then(/^target should match a baseline$/) do
  raise Applitools::EyesError, '@target is not set' unless @target
  @tag ||= ''
  expect(@target).to match_baseline(@tag)
end

Then(/^the element "([^"]*)" should match a baseline$/) do |query|
  step %(create target)
  step %(query element "#{query}")
  @target.region(@current_element) if @current_element
  step %(target should match a baseline)
end

Then(/^the entire element "([^"]*)" should match a baseline$/) do |query|
  step %(create target)
  step %(query element "#{query}")
  @target.region(@current_element).fully if @current_element
  step %(target should match a baseline)
end

Then(/^query element "([^"]*)"$/) do |query|
  step %(query element "#{query}" and take 0)
end

Then(/^I check viewport window$/) do
  step %(the whole screen should match a baseline)
end

Then(/^I check viewport window with description "([^"]*)"$/) do |description|
  step %(eyes tag is "#{description}")
  step %(I check viewport window)
end

Then(/^I check window$/) do
  step %(check for scrollable)
  if @present_scrollable
    step %(the entire element "#{@present_scrollable.element_query}" should match a baseline)
  else
    step %(I check viewport window)
  end
end

Then(/^I check window with description "([^"]*)"$/) do |description|
  step %(eyes tag is "#{description}")
  step %(I check window)
end

Then(/^I check viewport element "([^"]*)"$/) do |selector|
  step %(the element "#{selector}" should match a baseline)
end

Then(/^I check viewport element "([^"]*)" with description "([^"]*)"$/) do |selector, description|
  step %(eyes tag is "#{description}")
  step %(I check viewport element "#{selector}")
end

Then(/^I check element "([^"]*)"$/) do |selector|
  step %(the entire element "#{selector}" should match a baseline)
end

Then(/^I check element "([^"]*)" with description "([^"]*)"$/) do |selector, description|
  step %(eyes tag is "#{description}")
  step %(I check element "#{selector}")
end
