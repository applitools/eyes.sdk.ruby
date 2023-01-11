# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Applitools::Selenium::Target do
  it_should_behave_like 'responds to method', [
    :script_hook,
    :before_render_screenshot_hook
  ]
  context 'send_dom' do
    it 'Responds to \'send_dom\'' do
      expect(subject).to respond_to :use_dom
    end
    it 'Returns self' do
      expect(subject.send_dom(true).object_id).to eq subject.object_id
    end
    it 'Sets options' do
      subject.send_dom(false)
      expect(subject.options[:send_dom]).to be false
      subject.send_dom(true)
      expect(subject.options[:send_dom]).to be true
    end
    it 'Sets to true without params' do
      subject.send_dom(false)
      subject.send_dom
      expect(subject.options[:send_dom]).to be true
    end
    it ':use_dom default value' do
      expect(subject.options[:send_dom]).to be nil
    end
  end

  context 'use_dom' do
    it 'Responds to \'use_dom\'' do
      expect(subject).to respond_to :use_dom
    end
    it 'Returns self' do
      expect(subject.use_dom(true).object_id).to eq subject.object_id
    end
    it 'Sets options' do
      subject.use_dom(false)
      expect(subject.options[:use_dom]).to be false
      subject.use_dom(true)
      expect(subject.options[:use_dom]).to be true
    end
    it 'Sets to true without params' do
      subject.use_dom(false)
      subject.use_dom
      expect(subject.options[:use_dom]).to be true
    end
    it ':use_dom default value' do
      expect(subject.options[:use_dom]).to be nil
    end
  end

  context 'EnablePatterns' do
    it 'responds to :enable_patterns' do
      expect(subject).to respond_to(:enable_patterns)
    end
    it 'returns self' do
      expect(subject.enable_patterns(true).object_id).to eq subject.object_id
    end
    it 'set options' do
      subject.enable_patterns(false)
      expect(subject.options[:enable_patterns]).to be false
      subject.enable_patterns(true)
      expect(subject.options[:enable_patterns]).to be true
    end
    it 'sets to true without params' do
      subject.enable_patterns(false)
      subject.enable_patterns
      expect(subject.options[:enable_patterns]).to be true
    end
    it ':enable_patterns default value' do
      expect(subject.options[:enable_patterns]).to be nil
    end
  end
end
