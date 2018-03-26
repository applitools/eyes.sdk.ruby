# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Applitools::FloatingRegion do
  let(:subject) { described_class.new(10, 10, 20, 30, 40, 50, 60, 70) }
  it 'responds to :to_hash'
  context 'to_hash' do
    let(:a_hash) { subject.to_hash }
    it 'main coordinates' do
      expect(a_hash['Left']).to eq 10
      expect(a_hash['Top']).to eq 10
      expect(a_hash['Width']).to eq 20
      expect(a_hash['Height']).to eq 30
    end

    it 'max offsets' do
      expect(a_hash['MaxUpOffset']).to eq 50
      expect(a_hash['MaxLeftOffset']).to eq 40
      expect(a_hash['MaxRightOffset']).to eq 60
      expect(a_hash['MaxDownOffset']).to eq 70
    end
  end
end
