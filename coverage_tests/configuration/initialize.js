'use strict'
const {makeEmitTracker} = require('@applitools/sdk-coverage-tests')
const {checkSettingsParser, ruby, driverBuild, construct, ref, variable, getter, call, returnSyntax} = require('./parser')

module.exports = function (tracker, test) {
  const {addSyntax, addCommand, addHook} = tracker
  // addHook('deps', `require 'eyes_selenium'`)
  addSyntax('var', variable)
  addSyntax('getter', getter)
  addSyntax('call', call)
  addSyntax('return', returnSyntax)

  addHook(
      'beforeEach',
      driverBuild(),
  )

  addHook(
      'beforeEach',
      ruby`@eyes = eyes(is_visual_grid: ${test.vg}, is_css_stitching: ${test.config.stitchMode === 'CSS'}, branch_name: ${test.branchName})`,
  )

  addHook('afterEach', ruby`@driver.quit`)
  addHook('afterEach', ruby`@eyes.abort`)

  const driver = {
    constructor: {
      isStaleElementError() {
        addCommand(ruby`/stale element reference/`)
      }
    },
    visit(url) {
      return addCommand(ruby`@driver.get(${url})`)
    },
    getUrl() {
      return addCommand(ruby`@driver.get_url`)
    },
    executeScript(script, ...args) {
      return addCommand(ruby`@driver.execute_script(${script})`)
    },
    sleep(ms) {
      return addCommand(ruby`@driver.sleep(${Math.floor(ms/1000)})`)
    },
    switchToFrame(selector) {
      addCommand(ruby`@driver.switch_to.frame ${selector}`)
    },
    switchToParentFrame() {
      addCommand(ruby`@driver.switch_to.parent_frame`)
    },
    findElement(selector) {
      return addCommand(
          ruby`@driver.find_element(css: ${selector})`,
      )
    },
    findElements(selector) {
      return addCommand(
          ruby`@driver.find_elements(css: ${selector})`,
      )
    },
    click(element) {
      if(typeof element === 'object') addCommand(ruby`${element}.click`)
      else addCommand(ruby`@driver.find_element(css: ${element}).click`)
    },
    type(element, keys) {
      addCommand(ruby`${element}.send_keys(${keys})`)
    },
    scrollIntoView(element, align=false) {
      driver.executeScript('arguments[0].scrollIntoView(arguments[1])', element, align)
    },
    hover(element, offset){
      addCommand(ruby`@driver.action.move_to(${element}).perform`)
    },
  }

  const eyes = {
    constructor: {
      setViewportSize(viewportSize) {
        return addCommand(ruby`Applitools::Selenium::Eyes.set_viewport_size(@driver, width: ${viewportSize.width}, height: ${viewportSize.height});`)
      }
    },
    runner: {
      getAllTestResults(throwEx) {
        return addCommand(ruby`@eyes.runner.get_all_test_results(${throwEx})`)
      }
    },
    open({appName, testName, viewportSize}) {
      return addCommand(construct`@eyes.configure do |conf|`
          .add`  conf.app_name = ${appName || test.config.appName}`
          .add`  conf.test_name = ${testName || test.config.baselineName}`
          .extra`  conf.viewport_size = ${ref(viewportSize).type('RectangleSize')}`
          .add`end`
          .add`  @eyes.open(driver: @driver)`
          .build('\n  '))
    },
    check(checkSettings) {
      addCommand(`@eyes.check(${checkSettingsParser(checkSettings)})`)
    },
    checkWindow(tag, matchTimeout, stitchContent) {
      addCommand(ruby`@eyes.check_window(tag: ${tag}, timeout: ${matchTimeout})`)
    },
    checkFrame(element, matchTimeout, tag) {
      addCommand(ruby`@eyes.check_frame(frame: ${element}, timeout: ${matchTimeout}, tag: ${tag})`)
    },
    checkElementBy(selector, matchTimeout, tag) {
      addCommand(ruby`@eyes.check_region(:css, ${selector},
                       tag: ${tag},
                       match_timeout: ${matchTimeout})`)
    },
    checkRegion(region, matchTimeout, tag) {
      addCommand(ruby`@eyes.check_region(:css, ${selector},
                       tag: ${tag},
                       match_timeout: ${matchTimeout})`)
    },
    checkRegionInFrame(frameReference, selector, matchTimeout, tag, stitchContent) {
      addCommand(ruby`@eyes.check_region_in_frame(frame: ${frameReference},
                                by: [:css, ${selector}],
                                tag: ${tag},
                                stitch_content: ${stitchContent},
                                timeout: ${matchTimeout})`)
    },
    close(throwEx=true) {
      return addCommand(ruby`@eyes.close(${throwEx})`)
    },
    abort() {
      return addCommand(ruby`@eyes.abort`)
    },
    getViewportSize() {
      return addCommand(ruby`@eyes.get_viewport_size`)
    },
    locate() {
      return addCommand(ruby`raise 'Eyes locate method havent been implemented'`)
    },
  }

  const assert = {
    equal(actual, expected, message) {
      addCommand(construct`expect(${actual}).to eql(${expected})`.extra`, ${message}`.build())
    },
    notEqual(actual, expected, message) {
      addCommand(construct`expect(${actual}).not_to eql(${expected})`.extra`, ${message}`.build())
    },
    ok(value, message) {
      addCommand(construct`expect(${value}).to be_truthy`.extra`, ${message}`.build())
    },
    instanceOf(object, className, message) {
      addCommand(construct`expect(${object}).to be_a(${className})`.extra`, ${message}`.build())
    },
    throws(func, check) {
      let command
      if (check) {
        command = ruby`expect {${func}}.to raise_error(${check})`
      } else {
        command = ruby`expect {${func}}.to raise_error()`
      }
      addCommand(command)
    },
  }

  const helpers = {
    getTestInfo(result) {
      return addCommand(ruby`get_test_info(${result})`).type({
        type: 'TestInfo',
        schema: {
          actualAppOutput: {
            type: 'Array',
            items: {
              type: 'AppOutput',
              schema: {
                image: {
                  type: 'Image',
                  schema: {hasDom: 'Boolean'},
                },
                imageMatchSettings: {
                  type: 'ImageMatchSettings',
                  schema: {
                    ignoreDisplacements: 'Boolean',
                    ignore: {type: 'Array', items: 'Region'},
                    floating: {type: 'Array', items: 'FloatingRegion'},
                    accessibility: {type: 'Array', items: 'AccessibilityRegion'},
                    accessibilitySettings: {
                      type: 'AccessibilitySettings',
                      schema: {level: 'String', version: 'String'},
                    },
                    layout: {type: 'Array', items: 'Region'}
                  },
                }
              }},
          },
        },
      })
    }
  }

  return {helpers, driver, eyes, assert}
}