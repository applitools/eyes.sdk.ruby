# require_relative '../lib/eyes_selenium'
require 'eyes_images'
require 'logger'

eyes = Applitools::Images::Eyes.new
eyes.api_key = ENV['APPLITOOLS_API_KEY']
eyes.log_handler = Logger.new(STDOUT)

viber_home_image_bytes = File.read('./images/viber-home.png', mode: 'rb')
viber_home_image = Applitools::Screenshot.new viber_home_image_bytes

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
