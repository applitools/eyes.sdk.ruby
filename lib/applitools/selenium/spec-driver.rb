require 'applitools/universal_client/spec-driver'

Applitools::Selenium::SpecDriver = Applitools::UniversalClient::SpecDriver

# module Applitools
#   module Selenium
#     module SpecDriver
#       extend self
#
#       def isElement(element)
#         element.is_a? ::Selenium::WebDriver::Element
#       end
#
#       def isEqualElements(driver, element1, element2)
#         element1.hash == element2.hash
#       end
#
#       def executeScript(driver, script, args = [])
#         driver.execute_script(
#           script.start_with?('return') ? script : "return (#{script}).apply(null, arguments)",
#           *args
#         )
#       end
#
#       def mainContext(driver)
#         driver.switch_to.default_content
#       end
#
#       def parentContext(driver)
#         driver.switch_to.parent_frame
#       end
#
#       def childContext(driver, element)
#         driver.switch_to.frame(element)
#       end
#
#       def findElement(driver, selector)
#         driver.find_element(transformSelector(selector))
#       end
#
#       def findElements(driver, selector)
#         driver.find_elements(transformSelector(selector))
#       end
#
#       def getWindowRect(driver)
#         driver.manage.window.rect.to_h
#       end
#
#       def setWindowRect(driver, rect)
#         if rect[:width] && rect[:height]
#           driver.manage.window.resize_to(rect[:width], rect[:height])
#         end
#         if rect[:x] && rect[:y]
#           driver.manage.window.move_to(rect[:x], rect[:y])
#         end
#       end
#
#       def getTitle(driver)
#         driver.title
#       end
#
#       def getUrl(driver)
#         driver.current_url
#       end
#
#       def getDriverInfo(driver)
#         caps = driver.capabilities
#         {
#           :platformName => caps.platform,
#           :isMobile => caps.platform.include?(('android' or 'ios'))
#         }
#       end
#
#       def commands
#         self.instance_methods.map {|method_name| method_name.to_s}
#       end
#
#       def takeScreenshot(driver)
#         driver.screenshot_as(:base64)
#       end
#
#       private
#
#         def transformSelector(selector)
#           selector.is_a?(Hash) ? {selector[:type] => selector[:selector]} : {css: selector}
#         end
#
#     end
#   end
# end
