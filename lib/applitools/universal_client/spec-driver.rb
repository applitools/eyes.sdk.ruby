require('pry')

module Applitools::UniversalClient
  module SpecDriver
    extend self

    def isElement(element)
      element.is_a? ::Selenium::WebDriver::Element
    end

    def isEqualElements(driver, element1, element2)
      element1.hash == element2.hash
    end

    def executeScript(driver, script, arg)
      driver.execute_script(
        script.start_with?('return') ? script : "return (#{script}).apply(null, arguments)",
        arg
      )
    end

    def mainContext(driver)
      driver.switch_to.default_content
    end

    def parentContext(driver)
      driver.switch_to.parent_frame
    end

    def childContext(driver, element)
      driver.switch_to.frame(element)
    end

    def findElement(driver, selector)
      driver.find_element(transformSelector(selector))
    end

    def findElements(driver, selector)
      driver.find_elements(transformSelector(selector))
    end

    def getWindowRect(driver)
      driver.manage.window.rect.to_h
    end

    def setWindowRect(driver, rect)
      if rect[:width] && rect[:height]
        driver.manage.window.resize_to(rect[:width], rect[:height])
      end
      if rect[:x] && rect[:y]
        driver.manage.window.move_to(rect[:x], rect[:y])
      end
    end

    def getTitle(driver)
      driver.title
    end

    def getUrl(driver)
      driver.current_url
    end

    def getDriverInfo(driver)
      caps = driver.capabilities
      {
        :platformName => caps.platform,
        :isMobile => caps.platform.include?(('android' or 'ios'))
      }
    end

    def commands
      self.instance_methods.map {|method_name| method_name.to_s}
    end

    def takeScreenshot(driver)
      driver.screenshot_as(:base64)
    end

    private

    def transformSelector(selector)
      selector.is_a?(Hash) ? {selector[:type] => selector[:selector]} : {css: selector}
    end

    public


    # This command accepts driver instance as an argument and should return true if this is a valid driver instance,
    # otherwise false.
    def isDriver(driver)
      binding.pry
      # return utils.types.instanceOf(driver, 'WebDriver')
      # driver.is_a? ::Selenium::WebDriver
    end

    # This command accepts selector as an argument and should return true if this is a valid selector, otherwise false.
    # Valid selectors should be one of three formats:
    #
    # 1. The one supported by the framework (e.g. By.css('html') for selenium)
    # 2. JSON object with properties type with value "css" or "xpath" and selector with string value.
    # 3. Simple string, if the framework doesn't handle strings by itself, then the string should be treated as css selector.
    def isSelector(selector)
      # Selenium::WebDriver::SearchContext::FINDERS
      # {class: "class name", class_name: "class name", css: "css selector", id: "id", link: "link text",
      #   link_text: "link text", name: "name", partial_link_text: "partial link text", tag_name: "tag name",
      #   xpath: "xpath"}
      # how = selector.first
      # by = Selenium::WebDriver::SearchContext::FINDERS[how.to_sym]
      binding.pry
      # if (!selector) return false
      # return (
      #   utils.types.has(selector, ['type', 'selector']) ||
      #     utils.types.has(selector, ['using', 'value']) ||
      #     Object.keys(selector).some(key => byHash.includes(key)) ||
      #     utils.types.isString(selector)
      # )
    end

    # This command is used only once for the driver in order to do some modifications or even replacements in a given driver instance.
    # It might be helpful when some additional configuration is required before start working with the driver.
    # If this method implemented whenever will be returned from it will be used instead of the driver.
    def transformDriver(driver)
      binding.pry
      # if (process.env.APPLITOOLS_SELENIUM_MAJOR_VERSION === '3') {
      #   const cmd = require('selenium-webdriver/lib/command')
      # cmd.Name.SWITCH_TO_PARENT_FRAME = 'switchToParentFrame'
      # driver.getExecutor().defineCommand(cmd.Name.SWITCH_TO_PARENT_FRAME, 'POST', '/session/:sessionId/frame/parent')
      # }
      driver
    end

    # This command is used to transform elements before using them (e.g. as executeScript argument).
    # It accepts a value that has to be treated as an element, but the framework itself can't handle this value on its own.
    # Some frameworks might support more than one element format, and these formats might be not equal in terms of usage.
    def transformElement(element)
      # element.ref # => "9873fdb8-c0c5-48ff-b934-1006e942a28b"
      element.as_json # => {"element-6066-11e4-a52e-4f735466cecf"=>"9873fdb8-c0c5-48ff-b934-1006e942a28b"}
      # const elementId = extractElementId(element)
      # return {[ELEMENT_ID]: elementId, [LEGACY_ELEMENT_ID]: elementId}
    end

    # This command is used to extract a selector from an element object.
    # Not all frameworks keep information about the selector which was used to find an element,
    # but if does it will help to handle some edge cases with stale element errors.
    def extractSelector(element)
      element.attribute(:id) ? "\##{element.attribute(:id)}" : nil
    end

    # def extract_selector(element, or_new_val = nil, driver = nil)
    #   return "\##{element.attribute(:id)}" if element.attribute(:id)
    #   return nil if or_new_val.nil? || driver.nil?
    #   # hack to pass element to universal server
    #   selector_name = "data-#{Applitools::UniversalClient::Refer}"
    #   selector_val = element.attribute(selector_name)
    #   if selector_val.nil?
    #     script_string = "setApplitoolsDataAttribute = function(elem, val){elem.setAttribute('#{selector_name}', val);};setApplitoolsDataAttribute(arguments[0], arguments[1]);"
    #     driver.execute_script(script_string, element, or_new_val)
    #     selector_val = or_new_val
    #   end
    #   new_selector = "[#{selector_name}='#{selector_val}']"
    #   new_selector_check = driver.find_element(css: new_selector) === element
    #   raise Applitools::EyesDriverOperationException.new "Could not process #{element}" unless new_selector_check
    #   { type: :css, selector: new_selector }
    # end


    # This command is used to understand if an error is a stale element error,
    # it accepts an error object and should return true if the error is thrown because of element reference was stale.
    def isStaleElementError(error)
      binding.pry
      # if (!error) return false
      # error = error.originalError || error
      # return error instanceof Error && error.name === 'StaleElementReferenceError'
    end

    # This command is not required if the framework doesn't support native apps automation.
    # This command should return "landscape" or "portrait" strings in lowercase depends on device orientation.
    def getOrientation(browser_driver)
      binding.pry
      # const orientation = await browser.getOrientation()
      # return orientation.toLowerCase()
    end

    # This command is used to get metrics of the native element only. This command will not be used for the web,
    # since a more complex algorithm is required. The result should be returned as a JSON object with properties x, y, width and height,
    # values should remain fractional, no rounding is required.
    def getElementRect(driver, element)
      # element.rect.to_h # => {:x=>58, :y=>505.875, :width=>504, :height=>404}
      element.rect.to_h.to_json # => "{\"x\":58,\"y\":505.875,\"width\":504,\"height\":404}"
    end

    # This command should set viewport size from given JSON object with properties width and height.
    # size: {width: number; height: number}
    #
    # WD! Protocol doesn't allow to manipulate viewport directly. Implement setWindowRect and getWindowRect instead.
    #
    # def setViewportSize(page_driver, size)
    #   binding.pry
    #   # return page.setViewportSize(size)
    # end

    # This command should return the size of the viewport in the format of the JSON object with the properties width and height.
    # This command does not necessarily have to be implemented, since viewport size could be extracted from the browser,
    # but if it is possibly better to have it implemented since the framework could already have this information.
    #
    # WD! Protocol doesn't allow to manipulate viewport directly. Implement setWindowRect and getWindowRect instead.
    #
    # def getViewportSize(page_driver)
    #   binding.pry
    #   # return page.viewportSize()
    # end

  end
end
