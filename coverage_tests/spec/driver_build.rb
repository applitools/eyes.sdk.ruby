# frozen_string_literal: true
require 'driver_capabilities'


DEFAULT = {
  browser: 'chrome',
    headless: true
}.freeze

def deep_copy(o)
  Marshal.load(Marshal.dump(o))
end

def get_env(args = {})
  env = {
    url: CHROME_SERVER_URL,
      capabilities: {
        browserName: args[:browser] || ''
      }
  }
  env[:capabilities].merge!(args[:capabilities]) unless args[:capabilities].nil?
  env[:capabilities][:app] = args[:app] unless args[:app].nil?
  preset = DEVICES[args[:device]].clone || BROWSERS[args[:browser]].clone
  raise 'There were no preset ready for the used env' if preset.nil?
  env[:url] = preset[:url] unless preset[:url].nil?
  useLegacy = Selenium::WebDriver::VERSION.start_with?('3') && args[:legacy]
  mobileWeb = !args[:device].nil? && !args[:browser].nil?
  pre_caps = useLegacy ? preset[:capabilities][:legacy] : preset[:capabilities][:w3c] || preset[:capabilities]
  caps = deep_copy(pre_caps)
  if preset[:type] == 'sauce'
    if useLegacy
      env[:capabilities].merge!(preset[:options]) unless preset[:options].nil?
    else
      env[:capabilities]['sauce:options'] = preset[:options]
    end
  elsif args[:headless]
    browser_options_name = BROWSER_OPTIONS_NAME[caps[:browserName]]
    unless browser_options_name.nil?
      browser_options = caps[browser_options_name]
      browser_options[:args].push('headless')
    end
  end
  if mobileWeb
    if useLegacy
      caps[:browserName] = args[:browser]
    else
      caps[:browser_name] = args[:browser]
      caps[:browserName] = ''
    end
  end
  env[:type] = preset[:type]
  env[:capabilities].merge!(caps)
  print env
  env
end
