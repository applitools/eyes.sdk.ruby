# frozen_string_literal: true

require 'rspec'
require_relative '../lib/eyes_selenium'

RSpec.describe 'Simple examples for eyes_selenium' do
  let(:eyes) do
    Applitools::Selenium::Eyes.new('https://testeyes.applitools.com').tap do |eyes|
      eyes.api_key = ENV['APPLITOOLS_API_KEY']
      eyes.log_handler = logger
      eyes.match_level = Applitools::MATCH_LEVEL[:layout]
    end
  end

  let(:batch) { $batch ||= eyes.batch }

  let(:logger) { Logger.new(STDOUT) }

  let(:selenium_driver) { $selenium_driver ||= Selenium::WebDriver.for :chrome }

  let(:app_name) { 'eyes_selenium functionality test' }

  let!(:driver) do
    eyes.batch = batch
    eyes.open(
      driver: selenium_driver,
      app_name: app_name,
      test_name: RSpec.current_example.metadata[:full_description],
      viewport_size: vp_size
    )
  end

  before(:each) do
    driver.get('https://astappev.github.io/test-html-pages/')
  end

  after do
    eyes.close(true)
  end

  context 'common scrolling' do
    context 'legacy interface' do
      context 'check_window' do
        let(:vp_size) { { width: 800, height: 600 } }

        it('full page test') do
          eyes.force_full_page_screenshot = true
          eyes.check_window('check_window, full page, stitch_mode: scroll')
        end

        it('viewport test') do
          eyes.check_window('check_window, viewport screenshot, stitch_mode: scroll')
        end
      end

      context 'check_region' do
        let(:vp_size) { { width: 800, height: 270 } }

        it 'inside viewport' do
          eyes.check_region(
            :css, 'div#overflowing-div',
            tag: 'check_region (inside viewport), stitch_mode: scroll, force_fullpage_screenshot = false'
          )
        end

        it 'outside viewport' do
          eyes.check_region(
            :id, 'overflowing-div-image',
            tag: 'check_region (outside viewport), stitch_mode: scroll, force_fullpage_screenshot = false'
          )
        end
      end

      context 'check_region' do
        let(:vp_size) { { width: 800, height: 240 } }
        it 'partially outside' do
          eyes.check_region(
            :css, 'div#overflowing-div',
            tag: 'check_region (partially outside viewport), stitch_mode: scroll, force_fullpage_screenshot = false'
          )
        end
      end

      context 'using full page screenshot' do
        before do
          eyes.force_full_page_screenshot = true
        end
        context 'check_region' do
          let(:vp_size) { { width: 800, height: 270 } }

          it 'inside viewport' do
            eyes.check_region(
              :css, 'div#overflowing-div',
              tag: 'check_region (inside viewport), stitch_mode: scroll, force_fullpage_screenshot = true'
            )
          end

          it 'outside viewport' do
            eyes.check_region(
              :id, 'overflowing-div-image',
              tag: 'check_region (outside viewport), stitch_mode: scroll, force_fullpage_screenshot = true'
            )
          end
        end

        context 'check_region' do
          let(:vp_size) { { width: 800, height: 240 } }
          it 'partially outside' do
            eyes.check_region(
              :css, 'div#overflowing-div',
              tag: 'check_region (partially outside viewport), stitch_mode: scroll, force_fullpage_screenshot = true'
            )
          end
        end
      end

      context 'check overflowing region' do
        let(:vp_size) { { width: 800, height: 270 } }
        it 'overflowing region inside viewport' do
          eyes.check_region(
            :css, 'div#overflowing-div',
            stitch_content: true,
            tag: 'check_region, (inside viewport), stitch_content: true, stitch_mode: scroll, ' \
              'force_fullpage_screenshot = false'
          )
        end
        it 'overflowing region outside viewport' do
          eyes.check_region(
            :id, 'overflowing-div-image',
            stitch_content: true,
            tag: 'check_region, (outside viewport), stitch_content: true, stitch_mode: scroll, ' \
              'force_fullpage_screenshot = false'
          )
        end
      end

      context 'check overflowing region' do
        let(:vp_size) { { width: 800, height: 240 } }
        it 'overflowing region partially outside' do
          eyes.check_region(
            :css, 'div#overflowing-div', stitch_content: true,
            tag: 'check_region, (partially outside viewport), stitch_content: true, stitch_mode: scroll, ' \
              'force_fullpage_screenshot = false'
          )
        end
      end

      context 'check_frame' do
        let(:vp_size) { { width: 800, height: 700 } }
        it 'full frame' do
          eyes.check_frame(name_or_id: 'frame1', tag: 'check_frame')
        end

        context 'check region in frame' do
          let(:vp_size) { { width: 800, height: 600 } }
          it 'visible region' do
            eyes.check_region_in_frame(
              name_or_id: 'frame1', by: [:id, 'inner-frame-div'],
              stitch_content: false,
              tag: 'check_region_in_frame, stitch_content: false, stitch_mode: scroll'
            )
          end
          it 'stitched region' do
            eyes.check_region_in_frame(
              name_or_id: 'frame1', by: [:id, 'inner-frame-div'],
              stitch_content: true,
              tag: 'check_region_in_frame, stitch_content: true, stitch_mode: scroll'
            )
          end
        end
      end
    end

    context 'fluent interface' do
      context 'check_window'
      context 'check_region'
      context 'check_frame'
      context 'check_region_in_frame'
    end
  end

  context ':css scrolling' do
    before do
      eyes.stitch_mode = :css
    end
    context 'legacy interface' do
      context 'check_window' do
        let(:vp_size) { { width: 800, height: 600 } }

        it('full page test') do
          eyes.force_full_page_screenshot = true
          eyes.check_window('check_window, full page, stitch_mode: :css')
        end

        it('viewport test') do
          eyes.check_window('check_window, viewport screenshot, stitch_mode: :css')
        end
      end

      context 'check_region' do
        let(:vp_size) { { width: 800, height: 270 } }

        it 'inside viewport' do
          eyes.check_region(
            :css, 'div#overflowing-div',
            tag: 'check_region (inside viewport), stitch_mode: :css, force_fullpage_screenshot = false'
          )
        end

        it 'outside viewport' do
          eyes.check_region(
            :id, 'overflowing-div-image',
            tag: 'check_region (outside viewport), stitch_mode: :css, force_fullpage_screenshot = false'
          )
        end
      end

      context 'check_region' do
        let(:vp_size) { { width: 800, height: 240 } }
        it 'partially outside' do
          eyes.check_region(
            :css, 'div#overflowing-div',
            tag: 'check_region (partially outside viewport), stitch_mode: :css, force_fullpage_screenshot = false'
          )
        end
      end

      context 'using full page screenshot' do
        before do
          eyes.force_full_page_screenshot = true
        end
        context 'check_region' do
          let(:vp_size) { { width: 800, height: 270 } }

          it 'inside viewport' do
            eyes.check_region(
              :css, 'div#overflowing-div',
              tag: 'check_region (inside viewport), stitch_mode: :css, force_fullpage_screenshot = true'
            )
          end

          it 'outside viewport' do
            eyes.check_region(
              :id, 'overflowing-div-image',
              tag: 'check_region (outside viewport), stitch_mode: :css, force_fullpage_screenshot = true'
            )
          end
        end

        context 'check_region' do
          let(:vp_size) { { width: 800, height: 240 } }
          it 'partially outside' do
            eyes.check_region(
              :css, 'div#overflowing-div',
              tag: 'check_region (partially outside viewport), stitch_mode: :css, force_fullpage_screenshot = true'
            )
          end
        end
      end

      context 'check overflowing region' do
        let(:vp_size) { { width: 800, height: 270 } }
        it 'overflowing region inside viewport' do
          eyes.check_region(
            :css, 'div#overflowing-div',
            stitch_content: true,
            tag: 'check_region, (inside viewport), stitch_content: true, stitch_mode: :css, ' \
              'force_fullpage_screenshot = false'
          )
        end
        it 'overflowing region outside viewport' do
          eyes.check_region(
            :id, 'overflowing-div-image',
            stitch_content: true,
            tag: 'check_region, (outside viewport), stitch_content: true, stitch_mode: :css, ' \
              'force_fullpage_screenshot = false'
          )
        end
      end

      context 'check overflowing region' do
        let(:vp_size) { { width: 800, height: 240 } }
        it 'overflowing region partially outside' do
          eyes.check_region(
            :css, 'div#overflowing-div',
            stitch_content: true,
            tag: 'check_region, (partially outside viewport), stitch_content: true, ' \
              'stitch_mode: :css, force_fullpage_screenshot = false'
          )
        end
      end

      context 'check_frame' do
        let(:vp_size) { { width: 800, height: 700 } }
        it 'full frame' do
          eyes.check_frame(name_or_id: 'frame1', tag: 'check frame')
        end

        context 'check region in frame' do
          let(:vp_size) { { width: 800, height: 600 } }
          it 'visible region' do
            eyes.check_region_in_frame(
              name_or_id: 'frame1', by: [:id, 'inner-frame-div'],
              stitch_content: false,
              tag: 'check_region_in_frame, stitch_content: false, stitch_mode: :css'
            )
          end
          it 'stitched region' do
            eyes.check_region_in_frame(
              name_or_id: 'frame1', by: [:id, 'inner-frame-div'],
              stitch_content: true,
              tag: 'check_region_in_frame, stitch_content: true, stitch_mode: :css'
            )
          end
        end
      end
    end
    context 'fluent interface'
  end
end
