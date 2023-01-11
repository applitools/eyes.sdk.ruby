# frozen_string_literal: true

Then(/^set OS$/) do
  sdk_version = begin
                  perform_action('android_sdk_version')
                rescue HTTPClient::KeepAliveDisconnected
                  reinstall_apps
                  start_test_server_in_background
                  perform_action('android_sdk_version')
                end
  if sdk_version['success']
    Applitools::Calabash::EyesSettings.instance.eyes.host_os = Applitools::Calabash::OsVersions::Android.os_version(
      sdk_version['message']
    )
  end
end

Then(/^set device pixel ratio$/) do
  display_info = `#{default_device.adb_command} shell dumpsys display`
  # size_match = /deviceWidth=(?<width>\d+), deviceHeight=(?<height>\d+)/.match(display_info)
  density_match = /DisplayDeviceInfo.*density (?<density>\d+)/.match(display_info)
  Applitools::Calabash::EyesSettings.instance.eyes.device_pixel_ratio = density_match[:density].to_i
end

Then(/^set device physical size$/) do
  result = /mDefaultViewport=.*deviceWidth=(?<width>\d+).*deviceHeight=(?<height>\d+).*\n/.match(
    `#{default_device.adb_command} shell dumpsys display |grep mDefaultViewport`
  )
  step %(eyes viewport size is "#{result[:width].to_i}x#{result[:height].to_i}")
end

Then(/^set device size$/) do
  result = /^.*app=(?<width>\d+)x(?<height>\d+)/.match(
    `#{default_device.adb_command} shell dumpsys window displays |grep cur | tr -d ' '`
  )
  step %(eyes viewport size is "#{result[:width].to_i}x#{result[:height].to_i}")
end
