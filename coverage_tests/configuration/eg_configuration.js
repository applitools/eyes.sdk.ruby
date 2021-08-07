module.exports = {
    name: "eyes_selenium_ruby",
    emitter: "https://raw.githubusercontent.com/applitools/sdk.coverage.tests/eg_ruby/ruby/initialize.js",
    overrides: [
        "https://raw.githubusercontent.com/applitools/sdk.coverage.tests/eg_ruby/ruby/overrides.js",
        "https://raw.githubusercontent.com/applitools/sdk.coverage.tests/eg_ruby/eg.overrides.js"
    ],
    template: "https://raw.githubusercontent.com/applitools/sdk.coverage.tests/eg_ruby/ruby/template.hbs",
    ext: "_spec.rb",
    outPath: "./spec/coverage/generic"
};
