# frozen_string_literal: true

require_relative 'element_position_provider'
require_relative 'css_transform/css_transform'

module Applitools::Selenium
  # @!visibility private
  class CssTranslateElementPositionProvider < ElementPositionProvider
    include Applitools::CssTransform

    # Gets the current position.
    #
    # @return [Applitools::Location] The location.
    def current_position
      position = super.offset_negative transforms_offset
      logger.info "Current position is #{position}"
      position
    end

    def position=(location)
      super
      out_of_eyes = location.dup.offset_negative(current_position)
      return if out_of_eyes == Applitools::Location::TOP_LEFT
      logger.info "Moving element by #{out_of_eyes} to fit in the eyes region"

      Applitools::Utils::EyesSeleniumUtils.element_translate_to(
        driver,
        element,
        transforms_offset.offset_negative(out_of_eyes)
      )
      logger.info 'Done scrolling element!'
    end

    private

    def transforms_offset
      logger.info 'Getting element transforms...'
      transforms = Applitools::Utils::EyesSeleniumUtils.current_element_transforms(driver, element)
      logger.info "Current transforms: #{transforms}"
      transform_positions = transforms.values.compact.select { |s| !s.empty? }
                                      .map { |s| get_position_from_transform(s) }
      transform_positions.each do |p|
        raise Applitools::EyesError.new 'Got different css positions!' unless p == transform_positions[0]
      end
      transform_positions[0] || Applitools::Location::TOP_LEFT.dup
    end
  end
end
