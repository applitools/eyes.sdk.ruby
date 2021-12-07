module.exports = {
    name: 'eyes_selenium_ruby',
    emitter: 'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/universal-sdk/ruby/initialize.js',
    overrides: [
        'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/universal-sdk/js/overrides.js',
        "./configuration/ruby-overrides-universal",
    ],
    template: 'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/universal-sdk/ruby/template.hbs',
    ext: '_spec.rb',
    tests: 'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/universal-sdk/coverage-tests.js',
    outPath: './spec/coverage/generic',
}
