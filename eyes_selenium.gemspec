# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'applitools/version'

Gem::Specification.new do |spec|
  spec.name          = 'eyes_selenium'
  spec.version       = Applitools::VERSION
  spec.authors       = ['Applitools Team']
  spec.email         = ['team@applitools.com']
  spec.description   = 'Provides SDK for writing Applitools Selenium-based tests'
  spec.summary       = 'Applitools Ruby Selenium SDK'
  spec.homepage      = 'https://www.applitools.com'
  spec.license       = 'Applitools'

  spec.files         = `git ls-files lib/applitools/selenium`.split($RS) +
    ['lib/eyes_selenium.rb', 'lib/applitools/version.rb', 'lib/applitools/selenium/scripts/process_page_and_poll.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)
  spec.add_dependency 'eyes_core', "= #{Applitools::VERSION}"
  spec.add_dependency 'selenium-webdriver'
  spec.add_dependency 'css_parser'
  spec.add_dependency 'crass'
  spec.add_dependency 'state_machine'
  spec.add_dependency 'nokogiri'
end
