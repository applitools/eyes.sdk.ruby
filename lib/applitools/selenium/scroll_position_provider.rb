# frozen_string_literal: true

module Applitools::Selenium
  # @!visibility private
  class ScrollPositionProvider
    extend Forwardable

    def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=

    # Creates a new Applitools::Selenium::ScrollPositionProvider instance.
    #
    # @param [Applitools::Selenium::Driver] executor The instance that of the driver.
    # @param [Boolean] disable_horizontal Whether to disable horizontal movement or not.
    # @param [Boolean] disable_vertical Whether to disable vertical movement or not.
    def initialize(executor, disable_horizontal = false, disable_vertical = false, max_width = nil, max_height = nil)
      self.executor = executor
      self.disable_horizontal = disable_horizontal
      self.disable_vertical = disable_vertical
      self.max_width = max_width
      self.max_height = max_height
    end

    # The scroll position of the current frame.
    #
    # @return [Applitools::Location] The current position of the ScrollPositionProvider.
    def current_position
      logger.info 'current_position()'
      result = Applitools::Utils::EyesSeleniumUtils.current_scroll_position(executor)
      logger.info "Current position: #{result}"
      result
    rescue Applitools::EyesDriverOperationException
      raise 'Failed to extract current scroll position!'
    end

    def state
      current_position
    end

    def restore_state(value)
      self.position = value
    end

    def position=(value)
      logger.info "Scrolling to #{value}"
      Applitools::Utils::EyesSeleniumUtils.scroll_to(executor, value)
      logger.info 'Done scrolling!'
    end

    alias scroll_to position=

    # Returns the entire size of the viewport.
    #
    # @return [Applitools::RectangleSize] The viewport size.
    def entire_size
      viewport_size = Applitools::Utils::EyesSeleniumUtils.extract_viewport_size(executor)
      result = Applitools::Utils::EyesSeleniumUtils.entire_page_size(executor)
      logger.info "Entire size: #{result}"

      result.width = max_width unless max_width.nil?
      result.height = max_height unless max_height.nil?

      result.width = [viewport_size.width, result.width].min if disable_horizontal
      result.height = [viewport_size.height, result.height].min if disable_vertical
      logger.info "Actual size to scroll: #{result}"
      result
    end

    def force_offset
      Applitools::Location.new(0, 0)
    end

    private

    attr_accessor :executor, :disable_horizontal, :disable_vertical, :max_width, :max_height
  end
end
