module.exports = {
    name: 'eyes_selenium_ruby',
    emitter: 'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/execution_grid/ruby/initialize.js',
    overrides: [
        'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/execution_grid/ruby/overrides.js',
        'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/execution_grid/eg.overrides.js'
    ],
    template: 'https://raw.githubusercontent.com/applitools/sdk.coverage.tests/execution_grid/ruby/template.hbs',
    ext: '_spec.rb',
    outPath: './spec/coverage/generic'
}
