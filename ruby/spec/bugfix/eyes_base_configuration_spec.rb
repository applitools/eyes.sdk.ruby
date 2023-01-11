# frozen_string_literal: true
require 'eyes_selenium'

RSpec.describe Applitools::EyesBaseConfiguration do
  it 'save_new_tests default' do
    expect(subject).to respond_to :save_new_tests
    expect(subject.save_new_tests).to be_truthy
  end
end
