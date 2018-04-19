# frozen_string_literal: true

require 'spec_helper'
require 'eyes_selenium'

RSpec.describe Applitools::Selenium::Eyes, mock_connection: true do
  let(:element) { Selenium::WebDriver::Element.new('', nil) }
  let(:target_locator) do
    double.tap do |t|
      allow(t).to receive(:frame)
    end
  end
  let(:original_driver) do
    double(Selenium::WebDriver).tap do |d|
      allow(d).to receive(:driver_for_eyes).and_return(d)
      allow(d).to receive(:execute_script).and_return(100, 100)
      allow(d).to receive(:execute_script)
        .with(Applitools::Utils::EyesSeleniumUtils::JS_GET_CURRENT_SCROLL_POSITION)
        .and_return(left: 0, top: 0)
      allow(d).to receive(:user_agent).and_return(nil)
      allow(d).to receive(:frame_chain).and_return([])
    end
  end
  let(:driver) { Applitools::Selenium::Driver.new(subject, driver: original_driver) }
  let(:target) { Applitools::Selenium::Target.window }

  before do
    subject.api_key = 'API_KEY_FOR_TESTS'
  end

  context ':open' do
    it 'passes a block to :open_base block' do
      expect(subject).to receive(:open_base) do |*_args, &block|
        expect(block).to be_a Proc
      end
      subject.open(driver: driver, app_name: 'app_name', test_name: 'test_name')
    end

    it 'starts session on open' do
      expect(subject).to receive(:ensure_running_session)
      subject.open(driver: driver, app_name: 'app_name', test_name: 'test_name')
    end

    context 'respects :force_driver_resolution_as_viewport_size flag' do
      before do
        allow(subject).to receive(:get_viewport_size).and_return Applitools::RectangleSize.new(1, 1)
      end
      it 'ignores passed viewport_size if flag is set' do
        expect(subject).to_not receive(:set_viewport_size)
        subject.send(:force_driver_resolution_as_viewport_size=, true)
        subject.open(
          driver: driver, app_name: 'app_name', test_name: 'test_name', viewport_size: { width: 800, height: 600 }
        )
        expect(subject.viewport_size).to eq(Applitools::RectangleSize.new(1, 1))
      end

      it 'respects passed viewport_size by default' do
        expect(subject).to receive(:set_viewport_size) do |viewport_size, flag|
          expect(flag).to be true
          expect(viewport_size.width).to eq 800
          expect(viewport_size.height).to eq 600
        end
        subject.open(
          driver: driver, app_name: 'app_name', test_name: 'test_name', viewport_size: { width: 800, height: 600 }
        )
      end
    end

    context 'driver specific settings' do
      # module Appium
      #   class Driver; end
      # end
      let(:appium_driver) do
        double('Appium::Driver').tap do |drv|
          allow(drv).to receive(:driver_for_eyes).and_return(drv)
          allow(drv).to receive(:execute_script)
          allow(drv).to receive(:user_agent).and_return(nil)
          allow(drv).to receive(:class).and_return('Appium::Driver')
        end
      end
      it 'calls a method according to passed driver class' do
        expect(subject).to receive(:perform_driver_settings_for_appium_driver)
        subject.open(driver: appium_driver, app_name: 'app_name', test_name: 'test_name')
      end

      it 'appium_driver settings' do
        subject.send(:perform_driver_settings_for_appium_driver)
        expect(subject.send(:region_visibility_strategy)).to be_a Applitools::Selenium::NopRegionVisibilityStrategy
        expect(subject.send(:force_driver_resolution_as_viewport_size)).to be true
      end
    end
  end

  context ':check' do
    before do
      subject.open(driver: original_driver, app_name: 'app_name', test_name: 'test_name')
      allow_any_instance_of(Applitools::MatchWindowTask).to(
        receive(:match_window).and_return(Applitools::MatchResults.new)
      )
    end

    it 'performs \':read_target\' for match_data' do
      expect_any_instance_of(Applitools::MatchWindowData).to receive(:read_target)
      subject.check('', target)
    end

    it 'sets default values before \'reading\' target' do
      expect(subject).to(
        receive(:update_default_settings).with(Applitools::MatchWindowData).and_raise(Applitools::EyesError)
      )
      expect_any_instance_of(Applitools::MatchWindowData).to_not receive(:read_target)
      begin
        subject.check('', target)
      rescue Applitools::EyesError
        subject
      end
    end
  end
end

RSpec.describe 'Applitools::Selenium::Eyes' do
  context :obtain_screenshot_type do
    let(:klass) { Applitools::Selenium::Eyes }
    it '!element, !frame, !stitch, !force' do
      expect(klass.obtain_screenshot_type(false, false, false, false)).to eql(klass::VIEWPORT_SCREENSHOT)
    end
    it '!element, !frame, !stitch, force' do
      expect(klass.obtain_screenshot_type(false, false, false, true)).to eql(klass::FULLPAGE_SCREENSHOT)
    end
    it '!element, !frame, stitch, force' do
      expect(klass.obtain_screenshot_type(false, false, true, true)).to eql(klass::FULLPAGE_SCREENSHOT)
    end
    it '!element, !frame, stitch, !force' do
      expect(klass.obtain_screenshot_type(false, false, true, false)).to eql(klass::FULLPAGE_SCREENSHOT)
    end
    it '!element, frame, !stitch, !force' do
      expect(klass.obtain_screenshot_type(false, true, false, false)).to eql(klass::VIEWPORT_SCREENSHOT)
    end
    it '!element, frame, !stitch, force' do
      expect(klass.obtain_screenshot_type(false, true, false, true)).to eql(klass::ENTIRE_ELEMENT_SCREENSHOT)
    end
    it '!element, frame, stitch, force' do
      expect(klass.obtain_screenshot_type(false, true, true, true)).to eql(klass::ENTIRE_ELEMENT_SCREENSHOT)
    end
    it '!element, frame, stitch, !force' do
      expect(klass.obtain_screenshot_type(false, true, true, false)).to eql(klass::ENTIRE_ELEMENT_SCREENSHOT)
    end
    it 'element, frame, !stitch, !force' do
      expect(klass.obtain_screenshot_type(true, true, false, false)).to eql(klass::VIEWPORT_SCREENSHOT)
    end
    it 'element, frame, !stitch, force' do
      expect(klass.obtain_screenshot_type(true, true, false, true)).to eql(klass::ENTIRE_ELEMENT_SCREENSHOT)
    end
    it 'element, frame, stitch, force' do
      expect(klass.obtain_screenshot_type(true, true, true, true)).to eql(klass::ENTIRE_ELEMENT_SCREENSHOT)
    end
    it 'element, frame, stitch, !force' do
      expect(klass.obtain_screenshot_type(true, true, true, false)).to eql(klass::ENTIRE_ELEMENT_SCREENSHOT)
    end
    it 'element, !frame, !stitch, !force' do
      expect(klass.obtain_screenshot_type(true, false, false, false)).to eql(klass::VIEWPORT_SCREENSHOT)
    end
    it 'element, !frame, !stitch, force' do
      expect(klass.obtain_screenshot_type(true, false, false, true)).to eql(klass::FULLPAGE_SCREENSHOT)
    end
    it 'element, !frame, stitch, force' do
      expect(klass.obtain_screenshot_type(true, false, true, true)).to eql(klass::ENTIRE_ELEMENT_SCREENSHOT)
    end
    it 'element, !frame, stitch, !force' do
      expect(klass.obtain_screenshot_type(true, false, true, false)).to eql(klass::ENTIRE_ELEMENT_SCREENSHOT)
    end
  end
end
