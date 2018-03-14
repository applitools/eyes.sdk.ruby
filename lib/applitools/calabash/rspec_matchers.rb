# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :match_baseline do |expected|
  match do |actual|
    eyes = Applitools::Calabash::EyesSettings.instance.eyes
    result = eyes.check(expected, actual)
    eyes.new_session? || result.as_expected?
  end

  failure_message do |_actual|
    "expected #{expected} to match a baseline"
  end
end

RSpec::Matchers.define :be_success do
  match do |actual|
    actual.as_expected? == true
  end

  failure_message do |actual|
    "Expected eyes session to be successful, but mismatches occur. \n#{actual}"
  end
end
