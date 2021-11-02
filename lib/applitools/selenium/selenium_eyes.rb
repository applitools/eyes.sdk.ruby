# frozen_string_literal: false

module Applitools::Selenium
  # The main API gateway for the SDK
  class SeleniumEyes < Applitools::EyesBase

    def get_viewport_size
      # Applitools::ArgumentGuard.not_nil 'web_driver', @driver
      # self.utils.extract_viewport_size(driver)
      driver_config_json = @eyes_manager.driver_config(@driver)
      viewport_size = @universal_client.core_get_viewport_size(driver_config_json)
      Applitools::RectangleSize.new viewport_size[:width], viewport_size[:height]
    end

    # Set the viewport size.
    #
    # @param [Applitools::Selenium::Driver] driver The driver instance.
    # @param [Hash] viewport_size The required browser's viewport size.
    def self.set_viewport_size(driver, viewport_size)
      Applitools::ArgumentGuard.not_nil(driver, 'Driver')
      Applitools::ArgumentGuard.not_nil(viewport_size, 'viewport_size')
      Applitools::ArgumentGuard.is_a?(viewport_size, 'viewport_size', Applitools::RectangleSize)
      Applitools::EyesLogger.info "Set viewport size #{viewport_size}"
      begin
        driver_config_json = Applitools::UniversalClient::EyesManager.new(nil, nil).driver_config(driver)
        @universal_client = Applitools::UniversalClient::UniversalClient.new
        required_size = Applitools::RectangleSize.from_any_argument viewport_size
        @universal_client.core_set_viewport_size(driver_config_json, required_size.to_socket_output)
        # Applitools::Utils::EyesSeleniumUtils.set_viewport_size eyes_driver(driver), viewport_size
      rescue => e
        Applitools::EyesLogger.error e.class
        Applitools::EyesLogger.error e.message
        raise Applitools::EyesError.new 'Failed to set viewport size!'
      end
    end

    # export type OCRExtractSettings<TElement, TSelector> = {
    #   target: RegionReference<TElement, TSelector>
    #   hint?: string
    #   minMatch?: number
    #   language?: string
    # }
    def extract_text(targets_array)
      targets_array.map do |target|
        if Applitools::Selenium::SpecDriver.isElement(target['target'])
          # target['target'] = {type: :css, selector: target_to_selector(target['target'])}
          target['target'] = {elementId: target['target'].ref}
        end
        target
      end
      @eyes.extract_text(targets_array)
    end


    # export type OCRSearchSettings<TPattern extends string> = {
    #   patterns: TPattern[]
    #   ignoreCase?: boolean
    #   firstOnly?: boolean
    #   language?: string
    # }
    def extract_text_regions(patterns_array)
      results = @eyes.extract_text_regions(patterns_array)
      Applitools::Utils.deep_stringify_keys(results)
    end

    alias_method :extractText, :extract_text
    alias_method :extractTextRegions, :extract_text_regions

    # def target_to_selector element
    #   element.attribute(:id).empty? ? set_element_selector_proc.call(element) : "\##{element.attribute(:id)}"
    # end

    def locate(locate_settings)
      settings = {
        locatorNames: locate_settings[:locator_names],
        firstOnly: !!locate_settings[:first_only]
      }
      results = @eyes.locate(settings)
      Applitools::Utils.deep_stringify_keys(results)
    end

  end
end
