# frozen_string_literal: true

# require_relative '../lib/eyes_selenium'
require 'eyes_images'
require 'logger'

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

eyes = Applitools::Images::Eyes.new
eyes.api_key = ENV['APPLITOOLS_API_KEY']
eyes.log_handler = Logger.new(STDOUT)
# eyes.proxy = Applitools::Connectivity::Proxy.new 'http://localhost:9999'

viber_home_image_bytes = File.read('./images/viber-home.png', mode: 'rb')
viber_home_image = Applitools::Screenshot.from_datastream viber_home_image_bytes

eyes.test(app_name: 'Eyes.Java', test_name: 'home1') do
  eyes.check_image(image_path: './images/viber-home.png')
  eyes.check_region(
    image_bytes: viber_home_image_bytes,
    region: Applitools::Region.new(1773, 372, 180, 220),
    tag: 'Bada region'
  )
  eyes.add_mouse_trigger(:click, Applitools::Region::EMPTY, Applitools::Location.new(1866, 500))
  eyes.check_image(image_path: './images/viber-bada.png')
end

eyes.test(app_name: 'Eyes.Java', test_name: 'home2') do
  eyes.check_image(image: viber_home_image)
  eyes.check_image(image_path: './images/viber-bada.png')
end
