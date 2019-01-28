# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'applitools/version'

Gem::Specification.new do |spec|
  spec.name          = 'eyes_appium'
  spec.version       = Applitools::VERSION
  spec.version = "#{spec.version}-alpha-#{ENV['TRAVIS_BUILD_NUMBER']}" if ENV['TRAVIS']
  spec.authors       = ['Applitools Team']
  spec.email         = ['team@applitools.com']
  spec.description   = 'Appium support for Applitools Ruby SDK'
  spec.summary       = 'Appium support for Applitools Ruby SDK'
  spec.homepage      = 'https://www.applitools.com'
  spec.license       = 'Apache License, Version 2.0'

  spec.files         = `git ls-files lib/applitools/capybara`.split($RS) +
    ['lib/eyes_capybara.rb', 'lib/applitools/version.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)
  spec.add_dependency 'eyes_selenium', "= #{Applitools::VERSION}"
  spec.add_dependency 'appium_lib'
end
