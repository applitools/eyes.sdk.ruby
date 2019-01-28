# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'applitools/version'

Gem::Specification.new do |spec|
  spec.name          = 'eyes_calabash'
  spec.version       = Applitools::VERSION
  spec.version = "#{spec.version}-alpha-#{ENV['TRAVIS_BUILD_NUMBER']}" if ENV['TRAVIS']
  spec.authors       = ['Applitools Team']
  spec.email         = ['team@applitools.com']
  spec.description   = 'Applitools Ruby Calabash SDK'
  spec.summary       = 'Applitools Ruby Calabash SDK'
  spec.homepage      = 'https://www.applitools.com'
  spec.license       = 'Apache License, Version 2.0'

  spec.metadata['yard.run'] = 'yri' # use "yard" to build full HTML docs.

  spec.files         = `git ls-files lib/applitools/calabash`.split($RS) +
    ['lib/eyes_calabash.rb', 'lib/applitools/calabash_steps.rb', 'lib/applitools/version.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)
  spec.add_dependency 'cucumber'
  spec.add_dependency 'file_utils'
  spec.add_dependency 'rspec-expectations'
  spec.add_dependency 'eyes_core', "= #{Applitools::VERSION}"
end
