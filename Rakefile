#!/usr/bin/env rake
# frozen_string_literal: true

require 'rake/clean'
CLOBBER.include 'pkg'

require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks name: 'eyes_core'
Bundler::GemHelper.install_tasks name: 'eyes_images'
Bundler::GemHelper.install_tasks name: 'eyes_selenium'
Bundler::GemHelper.install_tasks name: 'eyes_calabash'

unless ENV['BUILD_ONLY']
  require 'rspec/core/rake_task'
  require 'rubocop/rake_task'

  options = ["api:#{ENV['TEST_API']}", "browser:#{ENV['TEST_IN_BROWSER']}"]

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--tag ~integration'
  end

  desc 'Checks if necessary environment variables are set'
  task :check_integration_test_required_variables do
    raise StandardError, 'Please set TEST_IN_BROWSER environment variable' unless
        ENV['TEST_IN_BROWSER'] && !ENV['TEST_IN_BROWSER'].empty?
    raise StandardError, 'Please set TEST_API environment variable' unless ENV['TEST_API'] && !ENV['TEST_API'].empty?
  end

  RSpec::Core::RakeTask.new(spec_integration: [:check_integration_test_required_variables]) do |t|
    t.rspec_opts = options.map { |o| '--tag ' + o }.join(' ')
  end

  RSpec::Core::RakeTask.new(:spec_integration_all) do |t|
    t.rspec_opts = '--tag integration'
  end

  RuboCop::RakeTask.new

  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
    task perform_tests: [:spec]
  else
    task perform_tests: [:rubocop, :spec]
  end

  if ENV['END_TO_END_TESTS']
    task :default => :spec_integration
  else
    task :default => :perform_tests
  end
end
