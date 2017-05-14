#!/usr/bin/env rake
require 'rake/clean'
CLOBBER.include 'pkg'

require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks name: 'eyes_core'
Bundler::GemHelper.install_tasks name: 'eyes_images'
Bundler::GemHelper.install_tasks name: 'eyes_selenium'

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new('spec')

RuboCop::RakeTask.new

task perform_tests: [:spec, :rubocop]
task :default => :perform_tests
