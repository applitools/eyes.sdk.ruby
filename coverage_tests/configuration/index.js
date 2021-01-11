const overrideTests = require('./ovveride-tests')
const initializeSdk = require('./initialize')
const testFrameworkTemplate = require('./template.hbs')

module.exports = {
  name: 'eyes_selenium_ruby',
  initializeSdk: initializeSdk,
  overrideTests,
  // testFrameworkTemplate: testFrameworkTemplate,
  template: './configuration/template.hbs',
  ext: '_spec.rb',
  outPath: './spec/coverage/generic'
}
