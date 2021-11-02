# frozen_string_literal: true
require 'driver_capabilities'

DEFAULT = {
  browser: 'chrome',
  headless: true
}.freeze

def get_env(args = {})
  args = DEFAULT.merge(args)
  env = {
    url: CHROME_SERVER_URL,
    capabilities: {
      browserName: args[:browser] || '',
    }
  }
  env[:capabilities].merge!(args[:capabilities]) unless args[:capabilities].nil?
  env[:capabilities][:app] = args[:app] unless args[:app].nil?
  preset = DEVICES[args[:device]].clone || BROWSERS[args[:browser]].clone
  raise 'There were no preset ready for the used env' if preset.nil?
  env[:type] = preset[:type] unless preset[:type].nil?
  env[:url] = preset[:url] unless preset[:url].nil?
  caps = args[:legacy] ? preset[:capabilities][:legacy] : preset[:capabilities][:w3c] || preset[:capabilities]
  if preset[:type] == 'sauce'
    if args[:legacy] || args[:device]
      env[:capabilities].merge!(preset[:options]) unless preset[:options].nil?
    else
      env[:capabilities]['sauce:options'] = preset[:options]
    end
  elsif args[:headless]
    browser_options_name = BROWSER_OPTIONS_NAME[caps[:browserName]]
    unless browser_options_name.nil?
      browser_options = caps[browser_options_name] || caps[browser_options_name.to_sym]
      browser_options[:args].push('headless')
    end
  end
  env[:capabilities].merge!(caps)
  env
end
