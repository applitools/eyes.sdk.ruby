# frozen_string_literal: true
require 'spec_helper'
require 'eyes_selenium'

RSpec.describe 'String replacements' do
  let(:dom_string) { 'kfdjdkfhkdsjhfksjdhzzz"@@@@@ttttttt@@@@@"zzz"@@@@@proba@@@@@"zzz' }
  let(:after_replacement) { 'kfdjdkfhkdsjhfksjdhzzzVALUE1zzzVALUE2zzz' }
  let(:replacements) { { 'ttttttt' => 'VALUE1', 'proba' => 'VALUE2' } }
  let(:start_token) { '"@@@@@' }
  let(:end_token) { '@@@@@"' }

  it do
    expect(
      Applitools::Selenium::DomCapture.replace(start_token, end_token, dom_string, replacements)
    ).to eq after_replacement
  end
end
