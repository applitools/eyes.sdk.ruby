'use strict'
const {makeEmitTracker} = require('@applitools/sdk-coverage-tests')
const {checkSettingsParser, ruby, driverBuild} = require('./parser')

function initialize(options) {
  const tracker = makeEmitTracker()

  // tracker.storeHook('deps', `require 'eyes_selenium'`)
  tracker.addSyntax('var', ({name, value}) => `${name} = ${value}`)
  tracker.addSyntax('getter', ({target, key}) => `${target}${key.startsWith('get') ? `.${key.slice(3).toLowerCase()}` : `["${key}"]`}`)
  tracker.addSyntax('call', ({target, args}) => args.length > 0 ? `${target}(${args.map(val => JSON.stringify(val)).join(", ")})` : `${target}`)

  tracker.storeHook(
      'beforeEach',
      driverBuild(options.capabilities, options.host),
  )

  tracker.storeHook(
      'beforeEach',
      ruby`@eyes = eyes(is_visual_grid: ${options.executionMode.isVisualGrid}, is_css_stitching: ${options.executionMode.isCssStitching}, branch_name: ${options.branchName})`,
  )

  tracker.storeHook('afterEach', ruby`@driver.quit`)
  tracker.storeHook('afterEach', ruby`@eyes.abort`)

  const driver = {
    build(options) {
      // TODO need implementation
      console.log('Need to be implemented')
    },
    cleanup() {
      tracker.storeCommand(ruby`@driver.quit`)
    },
    visit(url) {
      tracker.storeCommand(ruby`@driver.get(${url})`)
    },
    executeScript(script, ...args) {
      return tracker.storeCommand(ruby`@driver.execute_script(${script})`)
    },
    sleep(ms) {
      // TODO need implementation
      console.log(`Sleep Need to be implemented`)
    },
    switchToFrame(selector) {
      tracker.storeCommand(ruby`@driver.switch_to.frame ${selector}`)
    },
    switchToParentFrame() {
      // TODO need implementation
      console.log(`Switch to parent frame Need to be implemented`)
    },
    findElement(selector) {
      return tracker.storeCommand(
          ruby`@driver.find_element(css: ${selector})`,
      )
    },
    findElements(selector) {
      return tracker.storeCommand(
          ruby`@driver.find_elements(css: ${selector})`,
      )
    },
    getWindowLocation() {
      // TODO need implementation
      console.log('Get window location Need to be implemented')
    },
    setWindowLocation(location) {
      // TODO need implementation
      console.log('Set window location Need to be implemented')
    },
    getWindowSize() {
      // TODO need implementation
      console.log('get window size Need to be implemented')
    },
    setWindowSize(size) {
      // TODO need implementation
      console.log('set window size Need to be implemented')
    },
    click(element) {
      if(typeof element === 'object') tracker.storeCommand(ruby`${element}.click`)
      else tracker.storeCommand(ruby`@driver.find_element(css: ${element}).click`)
    },
    type(element, keys) {
      tracker.storeCommand(ruby`${element}.send_keys(${keys})`)
    },
    waitUntilDisplayed() {
      // TODO: implement if needed
    },
    getElementRect() {
      // TODO: implement if needed
    },
    getOrientation() {
      // TODO: implement if needed
    },
    isMobile() {
      // TODO: implement if needed
    },
    isAndroid() {
      // TODO: implement if needed
    },
    isIOS() {
      // TODO: implement if needed
    },
    isNative() {
      // TODO: implement if needed
    },
    getPlatformVersion() {
      // TODO: implement if needed
    },
    getBrowserName() {
      // TODO: implement if needed
    },
    getBrowserVersion() {
      // TODO: implement if needed
    },
    getSessionId() {
      // TODO: implement if needed
    },
    takeScreenshot() {
      // TODO: implement if needed
    },
    getTitle() {
      // TODO: implement if needed
    },
    getUrl() {
      // TODO: implement if needed
    },
  }

  const eyes = {
    open({appName, viewportSize}) {
      tracker.storeCommand(ruby`@eyes.configure do |conf|
      conf.app_name = ${appName}
      conf.test_name =  ${options.baselineTestName}
      conf.viewport_size = Applitools::RectangleSize.new(${viewportSize.width}, ${viewportSize.height})
    end
    @eyes.open(driver: @driver)`)
    },
    check(checkSettings) {
      tracker.storeCommand(`@eyes.check(${checkSettingsParser(checkSettings)})`)
    },
    checkWindow(tag, matchTimeout, stitchContent) {
      tracker.storeCommand(ruby`@eyes.check_window(tag: ${tag}, timeout: ${matchTimeout})`)
    },
    checkFrame(element, matchTimeout, tag) {
      tracker.storeCommand(ruby`@eyes.check_frame(frame: ${element}, timeout: ${matchTimeout}, tag: ${tag})`)
    },
    checkElement(element, matchTimeout, tag) {
      // TODO need implementation
      console.log('checkElement Need to be implemented')
    },
    checkElementBy(selector, matchTimeout, tag) {
      tracker.storeCommand(ruby`@eyes.check_region(:css, ${selector},
                       tag: ${tag},
                       match_timeout: ${matchTimeout},
                       stitch_content: true)`)
    },
    checkRegion(region, matchTimeout, tag) {
      tracker.storeCommand(ruby`@eyes.check_region(:css, ${selector},
                       tag: ${tag},
                       match_timeout: ${matchTimeout},
                       stitch_content: true)`)
    },
    checkRegionByElement(element, matchTimeout, tag) {
      // TODO need implementation
      console.log('checkRegionByElement Need to be implemented')
    },
    checkRegionBy(selector, tag, matchTimeout, stitchContent) {
      // TODO need implementation
      console.log('checkRegionBy Need to be implemented')
    },
    checkRegionInFrame(frameReference, selector, matchTimeout, tag, stitchContent) {
      tracker.storeCommand(ruby`@eyes.check_region_in_frame(frame: ${frameReference},
                                by: [:css, ${selector}],
                                tag: ${tag},
                                stitch_content: ${stitchContent},
                                timeout: ${matchTimeout})`)
    },
    close(throwEx) {
      tracker.storeCommand(ruby`@eyes.close(throw_exception: ${throwEx})`)
    },
    abort() {
      tracker.storeCommand(ruby`@eyes.abort`)
    },
    getViewportSize() {
      return tracker.storeCommand(ruby`@eyes.get_viewport_size`)
    },
  }

  const assert = {
    strictEqual(actual, expected, message) {
      tracker.storeCommand(ruby`expect(${actual}).to eql(${expected}), "${message}"`)
    },
    notStrictEqual(actual, expected, message) {
      console.log('Need to be implemented')
    },
    deepStrictEqual(actual, expected, message) {
      console.log('Need to be implemented')
    },
    notDeepStrictEqual(actual, expected, message) {
      console.log('Need to be implemented')
    },
    ok(value, message) {
      tracker.storeCommand(ruby`expect(${value}).to be_truthy, "${message}"`)
    },
  }

  return {tracker, driver, eyes, assert}
}

module.exports = {initialize}