# frozen_string_literal: true
require 'eyes_appium'

RSpec.describe 'Runner' do
  let(:runner) { Applitools::ClassicRunner.new }
  let(:appium_eyes) { Applitools::Appium::Eyes.new(runner: runner) }
  it 'for eyes_appium' do
    expect(appium_eyes.runner).to be(runner)
  end
end
