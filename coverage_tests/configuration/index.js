const overrideTests = require('./ovveride-tests')
const initializeSdk = require('./initialize')
const testFrameworkTemplate = require('./template')

module.exports = {
  name: 'eyes_selenium_ruby',
  initializeSdk: initializeSdk,
  overrideTests,
  testFrameworkTemplate: testFrameworkTemplate,
  ext: '_spec.rb',
  emitOnly: ['/should send floating region by coordinates with css stitching/'],
  outPath: './spec/coverage/generic'
}
