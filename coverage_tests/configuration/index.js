const overrideTests = require('./ovveride-tests')
const initializeSdk = require('./initialize')
const testFrameworkTemplate = require('./template')

module.exports = {
  name: 'eyes_selenium_ruby',
  initializeSdk: initializeSdk,
  overrideTests,
  testFrameworkTemplate: testFrameworkTemplate,
  ext: '_spec.rb',
  emitOnly: ['/should send dom and location /'],
  outPath: './spec/coverage/generic'
}
