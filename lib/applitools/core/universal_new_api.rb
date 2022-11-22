# frozen_string_literal: false

module Applitools
  module UniversalNewApi

    # export type OCRExtractSettings<TElement, TSelector> = {
    #   target: RegionReference<TElement, TSelector>
    #   hint?: string
    #   minMatch?: number
    #   language?: string
    # }
    def extract_text(targets_array)
      targets_array.map do |target|
        target['target'] = { elementId: target['target'].ref } if target['target'].is_a?(::Selenium::WebDriver::Element)
        target['target']['x'] = target['target'].delete('left') if target['target']['left']
        target['target']['y'] = target['target'].delete('top') if target['target']['top']
        target[:region] = target.delete('target')
        target
      end
      driver_target = driver.universal_driver_config
      universal_eyes.extract_text(targets_array, driver_target)
    end


    # export type OCRSearchSettings<TPattern extends string> = {
    #   patterns: TPattern[]
    #   ignoreCase?: boolean
    #   firstOnly?: boolean
    #   language?: string
    # }
    def extract_text_regions(patterns_array)
      driver_target = driver.universal_driver_config
      results = universal_eyes.extract_text_regions(patterns_array, driver_target)
      Applitools::Utils.deep_stringify_keys(results)
    end


    def locate(locate_settings)
      settings = {
        locatorNames: locate_settings[:locator_names],
        firstOnly: !!locate_settings[:first_only]
      }
      driver_target = driver.universal_driver_config
      results = universal_eyes.locate(settings, driver_target)
      Applitools::Utils.deep_stringify_keys(results)
    end

  end
end
