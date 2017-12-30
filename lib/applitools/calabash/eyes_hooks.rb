if respond_to?(:Before)
  Before('@eyes') do |scenario|
    get_scenario_tags(scenario)
    before_feature(scenario) if scenario.feature.children.first == scenario.source.last
  end

  Before('@eyes') do |scenario|
    Applitools::Calabash::EyesSettings.instance.eyes.add_context(self)
    step %(eyes test name is "#{@eyes_current_tags[:test_name] || scenario.name}")
    step %(open eyes)
  end
end

if respond_to?(:After)
  After('@eyes') do |scenario|
    after_feature(scenario) if scenario.feature.children.last == scenario.source.last
  end

  After('@eyes') do |_scenario|
    eyes = Applitools::Calabash::EyesSettings.instance.eyes
    Applitools::Calabash::EyesSettings.instance.eyes.remove_context if eyes && eyes.open?
    step %(terminate eyes session)
  end
end

def before_feature(scenario)
  @before_hook_scenario = scenario
  eyes_settings = Applitools::Calabash::EyesSettings.instance

  step %(eyes API key "#{@eyes_current_tags[:api_key] || ENV['APPLITOOLS_API_KEY']}") unless
    eyes_settings.applitools_api_key

  step %(eyes application name is "#{@eyes_current_tags[:app_name] || scenario.feature.name}")

  step %(set it up) if eyes_settings.needs_setting_up

  step %(create eyes)
end

def after_feature(_scenario) end

def get_scenario_tags(scenario)
  @eyes_current_tags = {}
  eyes_tag_name_regexp = /@eyes_(?<tag_name>[a-z,A-Z, \_]+) \"(?<value>.*)\"/
  scenario.tags.each do |t|
    match_data = t.name.match eyes_tag_name_regexp
    @eyes_current_tags[match_data[:tag_name].to_sym] = match_data[:value] if match_data
  end
end
