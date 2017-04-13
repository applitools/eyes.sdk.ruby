module Applitools::Selenium
  # @!visibility private
  class TakesScaledScreenshotImageProvider
    extend Forwardable
    def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=

    attr_accessor :driver, :name_enumerator, :device_pixel_ratio
    def initialize(driver, opts = {})
      self.driver = driver

      options = { debug_screenshot: false, device_pixel_ratio: 1 }.merge! opts

      self.debug_screenshot = options[:debug_screenshot]
      self.name_enumerator = options[:name_enumerator]
      self.device_pixel_ratio = options[:device_pixel_ratio]

      raise Applitools::EyesIllegalArgument.new "Expected device_pixel_ratio to be >= 1 (got #{device_pixel_ratio})" if
          device_pixel_ratio < 1
    end

    def take_screenshot
      logger.info 'Getting screenshot...'
      if debug_screenshot
        screenshot = driver.screenshot_as(:png) do |raw_screenshot|
          save_debug_screenshot(raw_screenshot)
        end
      else
        screenshot = driver.screenshot_as(:png)
      end
      logger.info 'Done getting screenshot! Creating Applitools::Screenshot...'
      Applitools::Screenshot::ScaledDatastream.new(screenshot, device_pixel_ratio)
    end

    def take_empty_screenshot(image_size)
      Applitools::ArgumentGuard.not_nil(image_size, :image_size)
      Applitools::ArgumentGuard.is_a?(Applitools::RectangleSize, image_size, :image_size)
      pixel_image_size = image_size.scale(device_pixel_ratio)
      Applitools::Screenshot::ScaledImage.new(
        ::ChunkyPNG::Image.new(pixel_image_size.width, pixel_image_size.height),
        device_pixel_ratio
      )
    end

    private

    attr_accessor :debug_screenshot

    def save_debug_screenshot(screenshot)
      ChunkyPNG::Image.from_string(screenshot).save(name_enumerator.next)
    end
  end
end
