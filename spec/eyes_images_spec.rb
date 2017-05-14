require 'spec_helper'

RSpec.describe Applitools::Images::Eyes do
  let(:image) { ChunkyPNG::Image.new(5, 5) }
  before(:each) { subject.default_match_settings[:match_level] = 'TEST' }
  describe ':check_image' do
    it 'passes match_level to base' do
      expect(subject).to receive(:check_window_base) do |*opts|
        expect(opts.last.match_level).to eq 'TEST'
      end.and_return(Applitools::MatchResults.new)
      subject.check_image(tag: 'nil', image: image)
    end
  end

  describe ':check_region' do
    it 'passes match_level to base' do
      expect(subject).to receive(:check_window_base) do |*opts|
        expect(opts.last.match_level).to eq 'TEST'
      end.and_return(Applitools::MatchResults.new)
      subject.check_region(tag: 'nil', image: image, region: Applitools::Region::EMPTY)
    end
  end
end
