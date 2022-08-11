# frozen_string_literal: true

require 'spec_helper'
require_relative 'test_utils'

# Applitools::EyesLogger.log_handler = Logger.new(STDOUT)

class ChildNode
  class ComparisonError < StandardError; end
  attr_accessor :tag, :hash
  def initialize(tag, hash)
    self.hash = hash
    self.tag = tag
  end

  def ==(other)
    result = true
    keys_to_compare.each do |k|
      result = false unless self[k] == other[k]
      raise ComparisonError, "#{tag}: \n#{self[k]} \n#{other[k]}" unless result
    end
    return false unless result
    my_child_nodes = child_nodes
    other_child_nodes = other.child_nodes
    return result if child_nodes.nil? && other_child_nodes.nil?
    raise ComparisonError, "#{tag}: child_nodes sizes are not equal" unless
        my_child_nodes.size == other_child_nodes.size
    child_nodes.each_with_index do |node, index|
      result = false unless
          ChildNode.new(child_tag(node['tagName']), node) == ChildNode.new(
            child_tag(other_child_nodes[index]['tagName']), other_child_nodes[index]
          )
      break unless result
    end
    result
  end

  def keys
    hash.keys
  end

  protected

  def keys_to_compare
    result = keys
    result.delete('childNodes')
    result
  end

  def[](key)
    hash[key]
  end

  def child_nodes
    self['childNodes']
  end

  private

  def child_tag(tn)
    tag + '->' + tn
  end
end

RSpec.describe 'TestSendDom' do
  class DomInterceptingEyes < Applitools::Selenium::SeleniumEyes
    attr_accessor :dom_json
    def dom_data
      self.dom_json = super
    end
  end

  def get_has_dom_(api_key, results)
    session_results = TestUtils.get_session_results(api_key, results)
    actual_app_outputs = session_results['actualAppOutput']
    expect(actual_app_outputs.length).to eq 1
    actual_app_outputs[0]['image']['hasDom']
  end

  let(:capabilities) do
    {
      browser_name: 'chrome',
      browser_version: 'latest',
      platform_name: 'Windows 10',
      'sauce:options' => {
        record_video: false,
        record_screenshots: false,
        username: ENV['SAUCE_USERNAME'],
        accesskey: ENV['SAUCE_ACCESSKEY'],
        screen_resolution: '1280x800'
      }
    }
  end
  let(:caps) { Selenium::WebDriver::Remote::Capabilities.chrome.merge!(capabilities) }

  let(:sauce_web_driver) do
    Selenium::WebDriver.for :remote, url: 'http://ondemand.saucelabs.com/wd/hub', desired_capabilities: capabilities
  end
  let(:local_web_driver) { Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: [:headless]) }
  let(:web_driver) { ENV['SAUCE_USERNAME'] && ENV['SAUCE_ACCESSKEY'] ? sauce_web_driver : local_web_driver }
  let(:eyes_web_driver) do |example|
    eyes.open(
      driver: web_driver,
      app_name: 'Test Send DOM',
      test_name: example.description,
      viewport_size: { width: 1024, height: 680 }
    )
  end

  context 'DomInterceptingEyes' do
    let(:eyes) { DomInterceptingEyes.new }
    it 'TestSendDOM_FullWindow' do
      eyes_web_driver.get('https://applitools.github.io/demo/TestPages/FramesTestPage/')

      begin
        eyes.check('window', Applitools::Selenium::Target.window.fully)
        actual_dom_json_string = Oj.load(eyes.dom_json)
        expected_dom_json = Oj.load(
          File.read(
            File.join(File.dirname(__FILE__), '/../fixtures/expected_dom1.json')
          )
        )
        results = eyes.close(false)
        has_dom = get_has_dom_(eyes.api_key, results)
        expect(ChildNode.new('', actual_dom_json_string)).to eq ChildNode.new('', expected_dom_json)
        expect(has_dom).to be_truthy
        session_results = TestUtils.get_session_results(eyes.api_key, results)
        actual_app_outputs = session_results['actualAppOutput']
        downloaded_dom_json = TestUtils.get_step_dom(eyes, actual_app_outputs[0])
        expect(downloaded_dom_json).to eq actual_dom_json_string
      ensure
        eyes.abort
        web_driver.quit
      end
    end
  end

  it 'TestSendDOM_Simple_HTML'
  it 'TestSendDOM_Selector'
  it 'TestNotSendDOM'
  it 'TestSendDOM_1'
  it 'TestSendDOM_2'
end
