# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative "lib/applitools/version"




Gem::Specification.new do |spec|
  spec.name          = 'eyes_universal'
  spec.version       = Applitools::UNIVERSAL_VERSION
  spec.authors       = ['Applitools Team']
  spec.email         = ['team@applitools.com']
  spec.description   = 'eyes-universal binaries for writing Applitools tests'
  spec.summary       = 'Applitools Ruby Universal binaries for SDK'
  spec.homepage      = 'https://www.applitools.com'
  spec.license       = 'Applitools'

  spec.files         = ['ext/eyes-universal/eyes-universal-linux']
end