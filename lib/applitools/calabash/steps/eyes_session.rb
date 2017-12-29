Then(/^create eyes$/) do
  eyes_settings = Applitools::Calabash::EyesSettings.instance
  eyes_settings.eyes ||= Applitools::Calabash::Eyes.new.tap do |eyes|
    eyes.api_key = eyes_settings.applitools_api_key
    log_file_path = File.join(eyes_settings.log_prefix, eyes_settings.log_file)
    eyes.log_handler = Logger.new(File.new(log_file_path, 'w+'))
  end

  unless eyes_settings.eyes.open?
    step %(set batch "#{@before_hook_scenario.feature.name}")
    step %(set OS)
    step %(set device pixel ratio)
    step %(set device size)
  end
end

Then(/^open eyes$/) do
  eyes_settings = Applitools::Calabash::EyesSettings.instance
  eyes_settings.eyes.open eyes_settings.options_for_open unless eyes_settings.eyes.open?
end

When(/^I close eyes session$/) do
  @test_result = Applitools::Calabash::EyesSettings.instance.eyes.close(false)
end

Then(/^test result should be positive$/) do
  raise Applitools::EyesError, 'Test result are not present!' unless @test_result
  expect(@test_result).to be_success
end

Then(/^applitools link should be reported$/) do
  puts @test_result
end

Then(/^terminate eyes session$/) do
  step %(I close eyes session)
  step %(test result should be positive)
  step %(applitools link should be reported)
  @test_results = nil
end
