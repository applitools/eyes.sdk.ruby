# frozen_string_literal: true

module Applitools
  class AppOutput
    attr_reader :title, :screenshot64, :location, :screenshot_url_getter, :dom_url_getter

    attr_accessor :dom_url, :screenshot_url, :visual_viewport

    def initialize(title, screenshot64)
      @title = title
      @screenshot64 = screenshot64
      @location = Applitools::Location::TOP_LEFT
      @screenshot_url_getter = nil
      @dom_url_getter = nil
    end

    def location=(value)
      Applitools::ArgumentGuard.is_a?(value, 'location', Applitools::Location)
      @location = value
    end

    def on_need_screenshot_url(&block)
      @screenshot_url_getter = block if block_given?
    end

    def on_need_dom_url(&block)
      @dom_url_getter = block if block_given?
    end

    def dom_url
      @dom_url ||= (@dom_url_getter && @dom_url_getter.call)
    end

    def to_hash
      result = {
        Title: title,
        Screenshot64: nil,
        Location: location.to_hash,
        ScreenshotUrl: screenshot_url || (screenshot_url_getter && screenshot_url_getter.call)
      }
      result[:DomUrl] = dom_url if dom_url
      result[:visualViewport] = visual_viewport if visual_viewport
      result
    end
  end
end
