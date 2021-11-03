module.exports = {
    name: 'eyes_selenium_ruby',
    emitter: 'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/test_ruby/ruby/initialize.js',
    overrides: [
        "https://raw.githubusercontent.com/applitools/sdk.coverage.tests/master/js/overrides.js",
        "./configuration/ruby-overrides-universal"
    ],
    template: 'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/master/ruby/template.hbs',
    ext: '_spec.rb',
    outPath: './spec/coverage/generic',
}
