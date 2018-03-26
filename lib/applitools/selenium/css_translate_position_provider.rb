# frozen_string_literal: true

module Applitools::Selenium
  class CssTranslatePositionProvider
    extend Forwardable

    def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=

    attr_accessor :last_state_position

    # Initialize a class instance.
    #
    # @param [Applitools::Selenium::Driver] executor The driver instance.
    # @param [Boolean] disable_horizontal Whether to disable horizontal movement or not.
    # @param [Boolean] disable_vertical Whether to disable vertical movement or not.
    # @param [Integer] max_width The max width.
    # @param [Integer] max_height The max height.
    def initialize(executor, disable_horizontal = false, disable_vertical = false, max_width = nil, max_height = nil)
      self.executor = executor
      self.disable_horizontal = disable_horizontal
      self.disable_vertical = disable_vertical
      self.max_width = max_width
      self.max_height = max_height
    end

    def current_position
      last_state_position
    end

    def state
      Applitools::Utils::EyesSeleniumUtils.current_transforms(executor)
    end

    # Restore last state position.
    #
    # @param [Applitools::Location] value The location.
    def restore_state(value)
      transforms = value.values.select { |el| !el.empty? }
      Applitools::Utils::EyesSeleniumUtils.set_transforms(executor, value)
      if transforms.empty?
        self.last_state_position = Applitools::Location::TOP_LEFT
      else
        positions = transforms.map { |s| get_position_from_transform(s) }
        positions.each { |p| raise Applitools::EyesError.new 'Got different css positions!' unless p == positions[0] }
        self.last_state_position = positions[0]
      end
    end

    def position=(value)
      Applitools::ArgumentGuard.not_nil(value, 'value')
      logger.info "Setting position to: #{value}"
      Applitools::Utils::EyesSeleniumUtils.translate_to(executor, value)
      logger.info 'Done!'
      self.last_state_position = value
    end

    def force_offset
      Applitools::Location.from_any_attribute last_state_position
      # Applitools::Location::TOP_LEFT
    end

    alias scroll_to position=

    # Gets the entire size of the frame.
    #
    # @return [Applitools::RectangleSize] The entire size of the frame.
    def entire_size
      viewport_size = Applitools::Utils::EyesSeleniumUtils.extract_viewport_size(executor)
      result = Applitools::Utils::EyesSeleniumUtils.current_frame_content_entire_size(executor)
      logger.info "Entire size: #{result}"
      result.width = max_width unless max_width.nil?
      result.height = max_height unless max_height.nil?

      result.width = [viewport_size.width, result.width].min if disable_horizontal
      result.height = [viewport_size.height, result.height].min if disable_vertical
      logger.info "Actual size to scroll: #{result}"
      result
    end

    private

    attr_accessor :executor, :disable_horizontal, :disable_vertical, :max_width, :max_height

    def get_position_from_transform(transform)
      regexp = /^translate\(\s*(\-?)(\d+)px,\s*(\-?)(\d+)px\s*\)/
      data = regexp.match(transform)
      raise Applitools::EyesError.new "Can't parse CSS transition: #{transform}!" unless data
      x = data[1].empty? ? data[2].to_i : -1 * data[2].to_i
      y = data[3].empty? ? data[4].to_i : -1 * data[4].to_i
      Applitools::Location.new(x, y)
    end
  end
end
