require 'spec_helper'

RSpec.shared_examples 'Classic API' do
  let(:url_for_test) { 'https://applitools.github.io/demo/TestPages/FramesTestPage/' }

  # it('TestCheckWindowFully') { eyes.check_window('Full Window', true) }
  #
  # it('TestCheckWindowViewport') { eyes.check_window('Viewport Window', false) }

  it('TestCheckWindow') { eyes.check_window('Window') }

  it('TestCheckRegion') { eyes.check_region(:id, 'overflowing-div', tag: 'Region', stitch_content: true) }

  it('TestCheckRegion2') { eyes.check_region(:id, 'overflowing-div-image', tag: 'minions', stitch_content: true) }

  it('TestCheckFrame') { eyes.check_frame(name_or_id: 'frame1', tag: 'frame1') }

  it('TestCheckRegionInFrame') { eyes.check_region_in_frame(name_or_id: 'frame1', by: [:id, 'inner-frame-div'], stitch_content: true, tag: 'Inner frame div') }

  it('TestCheckWindowAfterScroll') do
    driver.execute_script('document.documentElement.scrollTo(0,350);')
    eyes.check_window('viewport after scroll')
  end

  it('TestDoubleCheckWindow') do
    eyes.check_window('first')
    eyes.check_window('second')
    sleep 3
  end

  it('TestCheckInnerFrame') do
    eyes.hide_scrollbars = false
    driver.switch_to().default_content()
    driver.switch_to().frame(driver.find_element(:name, 'frame1'))
    eyes.check_frame(name_or_id: 'frame1-1', tag: 'inner-frame')
    eyes.logger.info('Validating (1)...')
    eyes.check_window('window after check frame')
    eyes.logger.info('Validating (2)...')
    inner_frame_body = driver.find_element(:tag_name, 'body')
    driver.execute_script('arguments[0].style.background=\'red\';', inner_frame_body)
    eyes.check_window('window after change background color of inner frame')
  end
end

# RSpec.describe 'Eyes Selenium SDK - Classic API', selenium: true do
#   describe do
#     include_examples 'Classic API'
#   end
#
#   context 'Stitch mode Scroll', scroll: true do
#     include_examples 'Classic API'
#   end
#
#   # describe 'Force Full Page Screenshot', fps: true do
#   #   include_examples 'Classic API'
#   # end
#   #
#   # describe 'Force Full Page Screenshot, Stitch mode Scroll', fps: true, scroll: true do
#   #   include_examples 'Classic API'
#   # end
# end


