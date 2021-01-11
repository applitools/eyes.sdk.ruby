'use strict'
const {makeEmitTracker} = require('@applitools/sdk-coverage-tests')
const {checkSettingsParser, ruby, driverBuild, construct, ref, variable, getter, call, returnSyntax, getClassName, prepareTestConfig} = require('./parser')
const {wrapSelector} = require('./util')


module.exports = function (tracker, test) {
  const {addSyntax, addCommand, addHook} = tracker
  if (test.meta.native) {
    addHook('deps', `require 'appium_helper'`)
    test.key += '_Native'
  } else {
    addHook('deps', `require 'selenium_helper'`)
  }
  addSyntax('var', variable)
  addSyntax('getter', getter)
  addSyntax('call', call)
  addSyntax('return', returnSyntax)

  addHook(
      'beforeEach',
      driverBuild(test.env),
  )

  addHook(
      'beforeEach',
      ruby`@eyes = eyes(is_visual_grid: ${test.vg}, is_css_stitching: ${test.config.stitchMode === 'CSS'}, branch_name: ${test.branchName})`,
  )

  if (test.config) {
    addHook('beforeEach', ruby`eyes_config(${ref(prepareTestConfig(test.config))})`)
  }

  addHook('afterEach', `@driver.${test.meta.native ? 'driver_quit' : 'quit'}`)
  addHook('afterEach', `@eyes.abort`)

  function frameSelector(frame){
    if(typeof frame === 'string' && !(/[#\[\]]/.test(frame))) {
      return frame
    } else {
      return ref(`{ css: ${JSON.stringify(frame)} }`)
    }
  }

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
      let command = construct`@driver.execute_script(${script}`
      args.forEach(val => command.extra`, ${val}`)
      command.add`)`
      return addCommand(command.build(''))
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
          ruby`@driver.find_element(${wrapSelector(selector)})`,
      )
    },
    findElements(selector) {
      return addCommand(
          ruby`@driver.find_elements(${wrapSelector(selector)})`,
      )
    },
    click(element) {
      if(element.isRef) addCommand(ruby`${element}.click`)
      else addCommand(ruby`${driver.findElement(element)}.click`)
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
          .add`    conf.app_name = ${appName || test.config.appName}`
          .add`    conf.test_name = ${testName || test.config.baselineName}`
          .extra`    conf.viewport_size = ${ref(viewportSize).type('RectangleSize')}`
          .add`  end`
          .addIf(test.meta.native)`  @eyes.open(driver: @driver)`
          .addIf(!test.meta.native)`  @driver = @eyes.open(driver: @driver)`
          .build('\n  '))
    },
    check(checkSettings = {}) {
      if (test.api !== 'classic') {
        return addCommand(`@eyes.check(${checkSettingsParser(checkSettings, driver, test.meta.native)})`)
      } else if (checkSettings.region) {
        if (checkSettings.frames && checkSettings.frames.length > 0) {
          const [frameReference] = checkSettings.frames
          return eyes.checkRegionInFrame(frameReference.frame || frameReference,
              checkSettings.region,
              checkSettings.timeout,
              checkSettings.name,
              checkSettings.isFully)
        }
        return eyes.checkRegion(checkSettings.region,
            checkSettings.timeout,
            checkSettings.name,
            checkSettings.isFully)
      } else if (checkSettings.frames && checkSettings.frames.length > 0) {
        const [frameReference] = checkSettings.frames
        return eyes.checkFrame(frameReference.frame || frameReference,
            checkSettings.timeout,
            checkSettings.name)
      } else {
        return eyes.checkWindow(checkSettings.name,
            checkSettings.timeout,
            checkSettings.isFully)
      }

    },
    checkWindow(tag, matchTimeout, stitchContent) {
      addCommand(ruby`@eyes.check_window(tag: ${tag}, timeout: ${matchTimeout}, stitchContent: ${stitchContent})`)
    },
    checkFrame(element, matchTimeout, tag) {
      addCommand(ruby`@eyes.check_frame(frame: ${frameSelector(element)}, timeout: ${matchTimeout}, tag: ${tag})`)
    },
    checkRegion(region, matchTimeout, tag, isFully) {
      addCommand(ruby`@eyes.check_region(:css, ${region},
                       tag: ${tag},
                       match_timeout: ${matchTimeout},
                       stitch_content: ${isFully})`)
    },
    checkRegionInFrame(frameReference, selector, matchTimeout, tag, stitchContent) {
      addCommand(ruby`@eyes.check_region_in_frame(frame: ${frameSelector(frameReference)},
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
      addCommand(construct`expect(${object}).to be_a(${getClassName(className)})`.extra`, ${message}`.build())
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
    },
    getDom(results, domId) {
      return addCommand(ruby`get_dom(${results}, ${domId})`).ref('dom')
    }
  }

  return {helpers, driver, eyes, assert}
}