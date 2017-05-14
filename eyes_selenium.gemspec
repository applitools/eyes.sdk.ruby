lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'applitools/version'
module Applitools::Selenium
  CURRENT_RUBY_VERSION = Gem::Version.new RUBY_VERSION

  RUBY_1_9_3 = Gem::Version.new '1.9.3'
  RUBY_2_0_0 = Gem::Version.new '2.0.0'
  RUBY_2_2_2 = Gem::Version.new '2.2.2'
  RUBY_2_4_0 = Gem::Version.new '2.4.0'

  RUBY_KEY = [RUBY_1_9_3, RUBY_2_0_0, RUBY_2_2_2, RUBY_2_4_0].select { |v| v <= CURRENT_RUBY_VERSION }.last

  EYES_GEM_SPECS = {
    RUBY_1_9_3 => proc {},
    RUBY_2_0_0 => proc do |spec|
      spec.add_dependency 'nokogiri', '~> 1.6'
    end,
    RUBY_2_2_2 => proc {},
    RUBY_2_4_0 => proc {}
  }.freeze
end

Gem::Specification.new do |spec|
  spec.name          = 'eyes_selenium'
  spec.version       = Applitools::VERSION
  spec.authors       = ['Applitools Team']
  spec.email         = ['team@applitools.com']
  spec.description   = 'Applitools Ruby Images SDK'
  spec.summary       = 'Applitools Ruby Images SDK'
  spec.homepage      = 'https://www.applitools.com'
  spec.license       = 'Apache License, Version 2.0'

  spec.files         = `git ls-files lib/applitools/selenium`.split($RS) +
    ['lib/eyes_selenium.rb', 'lib/applitools/capybara.rb', 'lib/applitools/version.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)
  spec.add_dependency 'eyes_core', "= #{Applitools::VERSION}"
  spec.add_dependency 'selenium-webdriver'
  spec.add_dependency 'capybara'
  spec.add_dependency 'watir'
  Applitools::Selenium::EYES_GEM_SPECS[Applitools::Selenium::RUBY_KEY].call spec
end
