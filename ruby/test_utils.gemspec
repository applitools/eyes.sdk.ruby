# frozen_string_literal: true

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'applitools/version'

module_files = `git ls-files lib/applitools/images`.split($RS) + `git ls-files lib/applitools/selenium`.split($RS) +
    ['lib/eyes_images', 'lib/applitools/capybara', 'lib/eyes_selenium']

Gem::Specification.new do |spec|
  spec.name          = 'test_utils'
  spec.version       = Applitools::VERSION
  spec.authors       = ['Applitools Team']
  spec.email         = ['team@applitools.com']
  spec.description   = "Don't use it directly, take a look at eyes_selenium, eyes_images or eyes_calabash gems instead."
  spec.summary       = 'Test utils to handle Applitools Ruby SDK test reporting'
  spec.homepage      = 'https://www.applitools.com'
  spec.license       = 'Applitools'

  spec.files         = `git ls-files lib/test_utils`.split($RS) +
      ['lib/require_utils.rb', 'lib/test_utils.rb', 'lib/eyes_rspec.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.metadata['yard.run'] = 'yri' # use "yard" to build full HTML docs.
end
