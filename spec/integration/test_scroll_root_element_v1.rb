# frozen_string_literal: true
require 'spec_helpoer'

RSpec.shared_examples 'Eyes Selenium SDK - Scroll Root Element' do
  let(:url_for_test) { 'https://applitools.github.io/demo/TestPages/SimpleTestPage/scrollablebody.html' }

  it 'TestCheckWindow_Body' do
    eyes.check(
      "Body ( #{eyes.stitch_mode} stitching)",
      Applitools::Selenium::Target.window.scroll_root_element(:tag_name, 'body').fully
    )
  end

  it 'TestCheckWindow_Html' do
    eyes.check(
      "Html ( #{eyes.stitch_mode} stitching)",
      Applitools::Selenium::Target.window.scroll_root_element(:tag_name, 'html').fully
    )
  end
end
