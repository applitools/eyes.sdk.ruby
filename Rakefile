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
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--tag ~integration'
  end

  RSpec::Core::RakeTask.new(:spec_integration) do |t|
    t.rspec_opts = '--tag integration'
  end

  RuboCop::RakeTask.new

  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
    task perform_tests: [:spec, :spec_integration]
  else
    task perform_tests: [:rubocop, :spec, :spec_integration]
  end
  task :default => :perform_tests
end
