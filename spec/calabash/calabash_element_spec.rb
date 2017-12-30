require 'spec_helper'

RSpec.describe 'Applitools::Calabash::CalabashElement' do
  let(:valid_original_hash) do
    {
      'rect' => {
        'x' => 10,
        'y' => 11,
        'width' => 12,
        'height' => 13,
        'center_x' => 5,
        'center_y' => 6
      }
    }
  end
  subject { Applitools::Calabash::CalabashElement.new(valid_original_hash, '*') }

  describe 'validates input hash' do
    it 'calls valid? on creation and raises an error on invalid data' do
      expect_any_instance_of(Applitools::Calabash::CalabashElement).to(
        receive(:valid_element?).with(Hash).and_return(false)
      )
      expect { Applitools::Calabash::CalabashElement.new({}, '*') }.to raise_error Applitools::EyesError
    end
    describe 'validation:' do
      before do
        allow_any_instance_of(Applitools::Calabash::CalabashElement).to receive(:valid_element?).and_call_original
      end
      it 'passes on valid data' do
        expect { Applitools::Calabash::CalabashElement.new(valid_original_hash, '*') }.to_not raise_error
      end
      context do
        after do
          expect { Applitools::Calabash::CalabashElement.new(valid_original_hash, '*') }.to(
            raise_error Applitools::EyesError
          )
        end
        it 'fails on "rect"' do
          valid_original_hash.delete('rect')
        end
        it 'fails on "x"' do
          valid_original_hash['rect'].delete('x')
        end
        it 'fails on "y"' do
          valid_original_hash['rect'].delete('y')
        end
        it 'fails on "width"' do
          valid_original_hash['rect'].delete('width')
        end
        it 'fails on "height"' do
          valid_original_hash['rect'].delete('height')
        end
        it 'fails on "center_x"' do
          valid_original_hash['rect'].delete('center_x')
        end
        it 'fails on "center_y"' do
          valid_original_hash['rect'].delete('center_y')
        end
      end
    end
  end

  it 'delegates :[] calls to original element' do
    expect(subject['rect']).to(
      include('x' => 10, 'y' => 11, 'width' => 12, 'height' => 13, 'center_x' => 5, 'center_y' => 6)
    )
  end

  it 'provides :left' do
    expect(subject.left).to eq 10
  end
  it 'provides :top' do
    expect(subject.top).to eq 11
  end
  it 'provides :width' do
    expect(subject.width).to eq 12
  end
  it 'provides :height' do
    expect(subject.height).to eq 13
  end

  it 'provides :x' do
    expect(subject.left).to eq 10
  end

  it 'provides :y' do
    expect(subject.top).to eq 11
  end

  it 'provides :location' do
    expect(subject.location).to eq Applitools::Location.from_any_attribute(subject.x, subject.y)
  end

  it 'provides :size' do
    expect(subject.size).to eq Applitools::RectangleSize.new(subject.width, subject.height)
  end
end
