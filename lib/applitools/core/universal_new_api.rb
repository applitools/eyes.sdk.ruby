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
        target
      end
      universal_eyes.extract_text(targets_array)
    end


    # export type OCRSearchSettings<TPattern extends string> = {
    #   patterns: TPattern[]
    #   ignoreCase?: boolean
    #   firstOnly?: boolean
    #   language?: string
    # }
    def extract_text_regions(patterns_array)
      results = universal_eyes.extract_text_regions(patterns_array)
      Applitools::Utils.deep_stringify_keys(results)
    end


    def locate(locate_settings)
      settings = {
        locatorNames: locate_settings[:locator_names],
        firstOnly: !!locate_settings[:first_only]
      }
      results = universal_eyes.locate(settings)
      Applitools::Utils.deep_stringify_keys(results)
    end

  end
end
