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
    outPath: './spec/coverage/generic',
    emitOnly: [
        'check window with css stitching',
        'check window with default fully with css stitching',
        'check window with scroll stitching classic',
        'check window with vg',
        'check window with default fully with vg',
        'check frame with css stitching',
        'check frame with vg',
        'check region by coordinates with css stitching',
        'check region by coordinates with vg',
    ],
};
