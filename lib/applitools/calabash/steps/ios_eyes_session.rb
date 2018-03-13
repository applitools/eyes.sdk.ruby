# frozen_string_literal: true

Then(/^set OS$/) do
  Applitools::Calabash::EyesSettings.instance.eyes.host_os = "iOS #{default_device.ios_major_version}"
end

Then(/^set device pixel ratio$/) do
  dimensions = default_device.screen_dimensions
  Applitools::Calabash::EyesSettings.instance.eyes.device_pixel_ratio = dimensions[:scale] #:native_scale?
end

Then(/^set device size$/) do
  dimensions = default_device.screen_dimensions
  step %(eyes viewport size is "#{dimensions[:width].to_i}x#{dimensions[:height].to_i}")
end
