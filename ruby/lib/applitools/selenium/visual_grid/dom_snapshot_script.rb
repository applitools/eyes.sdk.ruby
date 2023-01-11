# frozen_string_literal: false

require 'selenium-webdriver'


module Applitools
  module Selenium
    class DomSnapshotScript

      attr_accessor :driver

      def initialize(driver)
        self.driver = driver
      end

      def create_dom_snapshot(
        dont_fetch_resources,
        urls_to_skip,
        cross_origin_rendering,
        use_cookies
      )
        serialize_resources = true
        compress_resources = false
        script = DomSnapshotScript.new(driver, urls_to_skip, dont_fetch_resources, serialize_resources, compress_resources)
        snapshotter = RecursiveSnapshotter.new(driver, script, cross_origin_rendering, use_cookies)

        begin
          snapshotter.create_cross_frames_dom_snapshots
        rescue StandardError => e
          Applitools::EyesLogger.error e.class.to_s
          Applitools::EyesLogger.error e.message
          raise ::Applitools::EyesError.new 'Error while getting dom snapshot!'
        end

      end

      class DomSnapshotScript
        DOM_EXTRACTION_TIMEOUT = 300

        attr_accessor :driver, :urls_to_skip, :dont_fetch_resources, :serialize_resources, :compress_resources

        def initialize(driver, urls_to_skip, dont_fetch_resources, serialize_resources = false, compress_resources = false)
          self.driver = driver
          self.urls_to_skip = urls_to_skip
          self.dont_fetch_resources = dont_fetch_resources
          self.compress_resources = compress_resources
          self.serialize_resources = serialize_resources
        end

        def process_page_script
          ''
          # Applitools::Selenium::Scripts::PROCESS_PAGE_AND_POLL
        end

        def script_options
          options = []
          options.push("dontFetchResources: #{dont_fetch_resources}")
          options.push("skipResources: [#{urls_to_skip}]")
          options.push("compressResources: #{compress_resources}")
          options.push("serializeResources: #{serialize_resources}")
          "{#{options.join(', ')}}"
        end

        def script
          "#{process_page_script} return __processPageAndSerializePoll(#{script_options});"
        end

        def run
          Applitools::EyesLogger.info 'Trying to get DOM snapshot...'

          script_thread = Thread.new do
            result = {}
            while result['status'] != 'SUCCESS'
              Thread.current[:script_result] = driver.execute_script(script)
              begin
                Thread.current[:result] = result = Oj.load(Thread.current[:script_result])
                sleep 0.5
              rescue Oj::ParseError => e
                Applitools::EyesLogger.warn e.message
              end
            end
          end
          sleep 0.5
          script_thread_result = script_thread.join(DOM_EXTRACTION_TIMEOUT)
          raise ::Applitools::EyesError.new 'Timeout error while getting dom snapshot!' unless script_thread_result
          Applitools::EyesLogger.info 'Done!'

          script_thread_result[:result]['value']
        end

      end


      class RecursiveSnapshotter

        POLL_INTERVAL_MS = 0.5

        attr_accessor :should_skip_failed_frames

        attr_accessor :driver, :script, :cross_origin_rendering, :use_cookies

        def initialize(driver, script, cross_origin_rendering, use_cookies)
          self.should_skip_failed_frames = true
          self.driver = driver
          self.script = script
          self.cross_origin_rendering = cross_origin_rendering
          self.use_cookies = use_cookies
        end

        def create_cross_frames_dom_snapshots
          dom = create_dom_snapshot_threaded
          process_dom_snapshot_frames dom
          dom
        end

        def create_dom_snapshot_threaded
          script.run
        end

        def process_dom_snapshot_frames dom
          dom["cookies"] = driver.manage.all_cookies if use_cookies

          dom["frames"].each do |frame|
            selector = frame['selector']
            unless selector
              Applitools::EyesLogger.warn "inner frame with null selector"
              next
            end
            begin
              original_frame_chain = driver.frame_chain
              frame_element = driver.find_element(:css, selector)
              frame_src = frame_element.attribute('src')
              Applitools::EyesLogger.info "process_dom_snapshot_frames src = #{frame_src}"
              driver.switch_to.frame(frame_element)

              process_dom_snapshot_frames frame

              driver.switch_to.default_content
              unless original_frame_chain.empty?
                driver.switch_to.frames frame_chain: original_frame_chain
              end
            rescue StandardError => e
              Applitools::EyesLogger.error e.class.to_s
              Applitools::EyesLogger.error e.message
              if should_skip_failed_frames
                Applitools::EyesLogger.warn "failed switching to frame #{selector}"
              else
                raise ::Applitools::EyesError.new 'failed switching to frame'
              end
            end
          end

          self.snapshot_and_process_cors_frames(dom) if self.cross_origin_rendering
        end

        def snapshot_and_process_cors_frames(dom)
          dom["crossFrames"].each do |frame|
            selector = frame['selector']
            unless selector
              Applitools::EyesLogger.warn "cross frame with null selector"
              next
            end
            frame_index = frame['index']
            begin
              original_frame_chain = driver.frame_chain
              frame_element = driver.find_element(:css, selector) #
              frame_src = frame_element.attribute('src')
              Applitools::EyesLogger.info "snapshot_and_process_cors_frames src = #{frame_src}"
              driver.switch_to.frame(frame_element)

              frame_dom = create_cross_frames_dom_snapshots
              dom['frames'] ||= []
              dom['frames'].push frame_dom
              frame_url = frame_dom['url']
              dom['cdt'][frame_index]['attributes'].push({ 'name' => 'data-applitools-src', 'value' => frame_url })
              Applitools::EyesLogger.info "Created cross origin frame snapshot #{frame_url}"
              process_dom_snapshot_frames frame_dom

              driver.switch_to.default_content
              unless original_frame_chain.empty?
                driver.switch_to.frames(frame_chain: original_frame_chain)
              end
            rescue StandardError => e
              Applitools::EyesLogger.error e.class.to_s
              Applitools::EyesLogger.error e.message
              if should_skip_failed_frames
                Applitools::EyesLogger.warn "failed extracting and processing cross frame #{selector}"
              else
                raise ::Applitools::EyesError.new 'failed switching to frame'
              end
            end
          end
        end

      end
    end
  end
end
