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
  RSpec::Core::RakeTask.new('spec')
  RuboCop::RakeTask.new
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
    task perform_tests: [:spec]
  else
    task perform_tests: [:spec, :rubocop]
  end
  task :default => :perform_tests
end
