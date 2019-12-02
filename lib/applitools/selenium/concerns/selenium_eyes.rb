# frozen_string_literal: true

module Applitools
  module Selenium
    module Concerns
      module SeleniumEyes
        USE_DEFAULT_MATCH_TIMEOUT = -1

        # Validates the contents of an iframe and matches it with the expected output.
        #
        # @param [Hash] options The specific parameters of the desired screenshot.
        # @option options [Array] :target_frames The frames to check.
        def check_in_frame(options)
          Applitools::ArgumentGuard.is_a? options, 'options', Hash

          frames = options.delete :target_frames

          Applitools::ArgumentGuard.is_a? frames, 'target_frames: []', Array

          return yield if block_given? && frames.empty?

          original_frame_chain = driver.frame_chain

          logger.info 'Switching to target frame according to frames path...'
          driver.switch_to.frames(frames_path: frames)
          frame_chain_to_reset = driver.frame_chain
          logger.info 'Done!'

          ensure_frame_visible

          yield if block_given?

          reset_frames_scroll_position(frame_chain_to_reset)

          logger.info 'Switching back into top level frame...'
          driver.switch_to.default_content
          return unless original_frame_chain
          logger.info 'Switching back into original frame...'
          driver.switch_to.frames frame_chain: original_frame_chain
        end

        # Takes a snapshot of the application under test and matches it with the expected output.
        #
        # @param [String] tag An optional tag to be assosiated with the snapshot.
        # @param [Fixnum] match_timeout The amount of time to retry matching (seconds)
        # def check_window(tag = nil, match_timeout = USE_DEFAULT_MATCH_TIMEOUT)
        def check_window(*args)
          tag = args.select { |a| a.is_a?(String) || a.is_a?(Symbol) }.first
          match_timeout = args.select { |a| a.is_a?(Integer) }.first
          fully = args.select { |a| a.is_a?(TrueClass) || a.is_a?(FalseClass) }.first
          target = Applitools::Selenium::Target.window.tap do |t|
            t.timeout(match_timeout || USE_DEFAULT_MATCH_TIMEOUT)
            if is_a?(Applitools::Selenium::VisualGridEyes)
              t.fully(true)
            else
              t.fully(force_full_page_screenshot)
            end
            t.fully(fully) unless fully.nil?
          end
          check(tag, target)
        end

        # Takes a snapshot of the application under test and matches a region of
        # a specific element with the expected region output.
        #
        # @param [Applitools::Selenium::Element] element Represents a region to check.
        # @param [Symbol] how a finder, such :css or :id. Selects a finder will be used to find an element
        #   See Selenium::Webdriver::Element#find_element documentation for full list of possible finders.
        # @param [String] what The value will be passed to a specified finder. If finder is :css it must be a css selector.
        # @param [Hash] options
        # @option options [String] :tag An optional tag to be associated with the snapshot.
        # @option options [Fixnum] :match_timeout The amount of time to retry matching. (Seconds)
        # @option options [Boolean] :stitch_content If set to true, will try to get full content of the element
        #   (including hidden content due overflow settings) by scrolling the element,
        #   taking and stitching partial screenshots.
        # @example Check region by element
        #   check_region(element, tag: 'Check a region by element', match_timeout: 3, stitch_content: false)
        # @example Check region by css selector
        #   check_region(:css, '.form-row .input#e_mail', tag: 'Check a region by element', match_timeout: 3,
        #   stitch_content: false)
        # @!parse def check_region(element, how=nil, what=nil, options = {}); end
        def check_region(*args)
          options = { timeout: USE_DEFAULT_MATCH_TIMEOUT, tag: nil }.merge! Applitools::Utils.extract_options!(args)
          target = Applitools::Selenium::Target.new.region(*args).timeout(options[:match_timeout])
          target.fully if options[:stitch_content]
          check(options[:tag], target)
        end

        # Validates the contents of an iframe and matches it with the expected output.
        #
        # @param [Hash] options The specific parameters of the desired screenshot.
        # @option options [Fixnum] :timeout The amount of time to retry matching. (Seconds)
        # @option options [String] :tag An optional tag to be associated with the snapshot.
        # @option options [String] :frame Frame element or frame name or frame id.
        # @option options [String] :name_or_id The name or id of the target frame (deprecated. use :frame instead).
        # @option options [String] :frame_element The frame element (deprecated. use :frame instead).
        # @return [Applitools::MatchResult] The match results.

        def check_frame(options = {})
          options = { timeout: USE_DEFAULT_MATCH_TIMEOUT, tag: nil }.merge!(options)
          frame = options[:frame] || options[:frame_element] || options[:name_or_id]
          target = Applitools::Selenium::Target.frame(frame).timeout(options[:timeout]).fully
          check(options[:tag], target)
        end

        # Validates the contents of a region in an iframe and matches it with the expected output.
        #
        # @param [Hash] options The specific parameters of the desired screenshot.
        # @option options [String] :name_or_id The name or id of the target frame (deprecated. use :frame instead).
        # @option options [String] :frame_element The frame element (deprecated. use :frame instead).
        # @option options [String] :frame Frame element or frame name or frame id.
        # @option options [String] :tag An optional tag to be associated with the snapshot.
        # @option options [Symbol] :by By which identifier to find the region (e.g :css, :id).
        # @option options [Fixnum] :timeout The amount of time to retry matching. (Seconds)
        # @option options [Boolean] :stitch_content Whether to stitch the content or not.
        # @return [Applitools::MatchResult] The match results.
        def check_region_in_frame(options = {})
          options = { timeout: USE_DEFAULT_MATCH_TIMEOUT, tag: nil, stitch_content: false }.merge!(options)
          Applitools::ArgumentGuard.not_nil options[:by], 'options[:by]'
          Applitools::ArgumentGuard.is_a? options[:by], 'options[:by]', Array

          how_what = options.delete(:by)
          frame = options[:frame] || options[:frame_element] || options[:name_or_id]

          target = Applitools::Selenium::Target.new.timeout(options[:timeout])
          target.frame(frame) if frame
          target.fully if options[:stitch_content]
          target.region(*how_what)

          check(options[:tag], target)
        end

        # Use this method to perform seamless testing with selenium through eyes driver.
        # It yields a block and passes to it an Applitools::Selenium::Driver instance, which wraps standard driver.
        # Using Selenium methods inside the 'test' block will send the messages to Selenium
        # after creating the Eyes triggers for them. Options are similar to {open}
        # @yieldparam driver [Applitools::Selenium::Driver] Gives a driver to a block, which translates calls to a native
        #   Selemium::Driver instance
        # @example
        #   eyes.test(app_name: 'my app', test_name: 'my test') do |driver|
        #      driver.get "http://www.google.com"
        #      driver.check_window("initial")
        #   end
        def test(options = {}, &_block)
          open(options)
          yield(driver)
          close
        ensure
          abort_if_not_closed
        end
      end
    end
  end
end
