# frozen_string_literal: true

module Applitools::Selenium
  # @!visibility private
  class Keyboard
    attr_reader :keyboard, :driver

    # Creates a new Applitools::Selenium::Keyboard instance.
    #
    # @param [Applitools::Selenium::Driver] driver The driver instance.
    # @param [Selenium::WebDriver::Keyboard] keyboard The keyboard instance.
    def initialize(driver, keyboard)
      @driver = driver
      @keyboard = keyboard
    end

    # Types the keys into a text box.
    #
    # @param [Array] keys The keys to type into the text box.
    def send_keys(*keys)
      active_element = Applitools::Selenium::Element.new(driver, driver.switch_to.active_element)
      current_control = active_element.region
      Selenium::WebDriver::Keys.encode(keys).each do |key|
        driver.user_inputs << Applitools::Base::TextTrigger.new(key.to_s, current_control)
      end
      keyboard.send_keys(*keys)
    end

    # Press the key.
    #
    # @param [String] key The key to press.
    def press(key)
      keyboard.press(key)
    end

    # Release the key.
    #
    # @param [String] key The key to release.
    def release(key)
      keyboard.release(key)
    end
  end
end
