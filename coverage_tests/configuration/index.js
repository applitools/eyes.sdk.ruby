const supportedTests = require('./supported-tests')
const {initialize} = require('./initialize')
const testFrameworkTemplate = require('./template')

module.exports = {
  name: 'eyes_selenium_ruby',
  initialize: initialize,
  supportedTests,
  testFrameworkTemplate: testFrameworkTemplate,
  ext: '_spec.rb',
  out: './spec/coverage/generic'
}
