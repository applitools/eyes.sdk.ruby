# frozen_string_literal: true

Given(/^eyes application name is "([^"]*)"$/) do |name|
  Applitools::Calabash::EyesSettings.instance.app_name = name
end

Given(/^eyes test name is "([^"]*)"$/) do |name|
  Applitools::Calabash::EyesSettings.instance.test_name = name
end

Given(/^eyes viewport size is "([^"]*)"$/) do |size|
  Applitools::Calabash::EyesSettings.instance.viewport_size = Applitools::RectangleSize.from_any_argument(size)
end

Given(/^eyes API key "([^"]*)"$/) do |key|
  Applitools::Calabash::EyesSettings.instance.applitools_api_key = key
end

Given(/^eyes tag is "([^"]*)"$/) do |tag|
  @tag = tag
end

Given(/^set batch "([^"]*)"/) do |name|
  @current_batch ||= Applitools::Calabash::EyesSettings.instance.eyes.batch.tap do |batch|
    batch.name = name
  end

  Applitools::Calabash::EyesSettings.instance.eyes.batch = @current_batch
end

Given(/^calabash screenshot dir is "([^"]*)"$/) do |path|
  Applitools::Calabash::EyesSettings.instance.screenshot_dir = path
end

Given(/^calabash temp dir is "([^"]*)"$/) do |path|
  Applitools::Calabash::EyesSettings.instance.tmp_dir = path
end

Given(/^calabash log path is "([^"]*)"$/) do |path|
  Applitools::Calabash::EyesSettings.instance.log_dir = path
end

Given(/^eyes logfile is "([^"]*)"$/) do |logfile_path|
  Applitools::Calabash::EyesSettings.instance.log_file = logfile_path
end

Given(/^clear directories$/) do
  Applitools::Calabash::Utils.clear_directories(Applitools::Calabash::EyesSettings.instance)
end

Given(/^create directories$/) do
  Applitools::Calabash::Utils.create_directories(Applitools::Calabash::EyesSettings.instance)
end

Given(/^set it up$/) do
  step %(clear directories)
  step %(create directories)
  Applitools::Calabash::EyesSettings.instance.needs_setting_up = false
end
