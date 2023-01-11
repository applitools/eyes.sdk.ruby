# frozen_string_literal: true
require 'spec_helper'

RSpec.shared_examples 'Eyes Selenium SDK - Simple Test Cases' do
  let(:url_for_test) { 'https://applitools.github.io/demo/TestPages/SimpleTestPage/' }
  let(:viewport_size) { { width: 1024, height: 600 } }

  it 'TestCheckDivOverflowingThePage' do
    eyes.check('overflowing div', Applitools::Selenium::Target.region(:id, 'overflowing-div').fully)
  end
end
