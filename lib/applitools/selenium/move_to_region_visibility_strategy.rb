module Applitools::Selenium
  # @!visibility private
  class MoveToRegionVisibilityStrategy
    extend Forwardable

    VISIBILITY_OFFSET = 100

    def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=
    attr_accessor :original_position

    # Set the location of the position provider.
    #
    # @param [Applitools::Selenium::CssTranslatePositionProvider, Applitools::Selenium::ScrollPositionProvider]
    # position_provider The position provider type (e.g. Applitools::Selenium::CssTranslatePositionProvider,
    # Applitools::Selenium::ScrollPositionProvider).
    # @param [Applitools::Location] location The location to move to.
    def move_to_region(position_provider, location)
      logger.info 'Getting current position state...'
      self.original_position = position_provider.state

      dst_x = location.x - VISIBILITY_OFFSET
      dst_y = location.y - VISIBILITY_OFFSET

      dst_x = 0 if dst_x < 0
      dst_y = 0 if dst_y < 0

      logger.info "Done! Setting position to #{location}..."

      position_provider.position = Applitools::Location.new(dst_x, dst_y)
      logger.info 'Done!'
    end

    # Return the position provider to its original position.
    #
    # @param [Applitools::Selenium::CssTranslatePositionProvider, Applitools::Selenium::ScrollPositionProvider]
    # position_provider The position provider type (e.g. Applitools::Selenium::CssTranslatePositionProvider,
    # Applitools::Selenium::ScrollPositionProvider).
    def return_to_original_position(position_provider)
      return if original_position.nil?
      logger.info 'Returning to original position...'
      position_provider.restore_state original_position
      logger.info 'Done!'
    end
  end
end
