# frozen_string_literal: true

module Applitools::Selenium
  # @!visibility private
  class TakesScreenshotImageProvider
    extend Forwardable
    def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=

    attr_accessor :driver, :debug_screenshot_provider

    # Initialize an Applitools::Selenium::TakesScreenshotImageProvider.
    #
    # @param [Applitools::Selenium::Driver] driver
    # @param [Hash] options The options for taking a screenshot.
    # @option options [Boolean] :debug_screenshot
    # @option options [Enumerator] :name_enumerator The name enumerator.
    def initialize(driver, options = {})
      self.driver = driver
      options = { debug_screenshot: false }.merge! options
      self.debug_screenshot_provider = options[:debug_screenshot_provider]
    end

    # Takes a screenshot.
    #
    # @return [Applitools::Screenshot::Datastream] The screenshot.
    def take_screenshot(options = {})
      logger.info 'Getting screenshot...'
      screenshot = driver.screenshot_as(:png) do |raw_screenshot|
        save_debug_screenshot(raw_screenshot, options[:debug_suffix])
      end
      logger.info 'Done getting screenshot! Creating Applitools::Screenshot...'
      Applitools::Screenshot.from_datastream screenshot
    end

    private

    attr_accessor :debug_screenshot

    def save_debug_screenshot(screenshot, suffix)
      debug_screenshot_provider.save(screenshot, suffix || '')
    end
  end
end
