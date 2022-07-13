module.exports = {
    name: 'eyes_selenium_ruby',
    emitter: 'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/universal-sdk/ruby/initialize.js',
    overrides: [
        'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/universal-sdk/js/overrides.js',
        'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/universal-sdk/ruby/overrides.js',
    ],
    template: 'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/universal-sdk/ruby/template.hbs',
    tests: 'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/universal-sdk/coverage-tests.js',
    ext: '_spec.rb',
    emitOnly: ['/check window fully on page with horizontal scroll with/'],
    outPath: './spec/coverage/generic'
};
