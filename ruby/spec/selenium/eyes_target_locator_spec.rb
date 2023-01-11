# frozen_string_literal: true

require 'spec_helper'

class WillSwitchToFrame
  def will_switch_to_frame(*args); end
end

RSpec.describe 'Applitools::Selenium::EyesTargetLocator' do
  let(:native_target_locator) { instance_double(Selenium::WebDriver::TargetLocator) }
  let(:driver) { instance_double Applitools::Selenium::Driver }
  let(:on_will_switch) { WillSwitchToFrame.new }
  let(:subject) { Applitools::Selenium::EyesTargetLocator.new(driver, native_target_locator, on_will_switch) }

  context ':frame' do
    it 'accepts a string as an argument' do
      allow(driver).to receive(:find_elements).and_return([true])
      allow(driver).to receive(:find_element)
      allow(native_target_locator).to receive(:frame)
      expect { subject.frame('frame1') }.to_not raise_error
    end

    it 'passes a string to :frame_by_name_or_id' do
      expect(subject).to receive(:frame_by_name_or_id).with('frame_request')
      subject.frame('frame_request')
    end
  end
end
