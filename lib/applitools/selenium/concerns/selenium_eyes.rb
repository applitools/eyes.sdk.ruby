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
        # def check_in_frame(options)
        #   Applitools::ArgumentGuard.is_a? options, 'options', Hash
        #
        #   frames = options.delete :target_frames
        #
        #   Applitools::ArgumentGuard.is_a? frames, 'target_frames: []', Array
        #
        #   return yield if block_given? && frames.empty?
        #
        #   original_frame_chain = driver.frame_chain
        #
        #   logger.info 'Switching to target frame according to frames path...'
        #   driver.switch_to.frames(frames_path: frames)
        #   frame_chain_to_reset = driver.frame_chain
        #   logger.info 'Done!'
        #
        #   ensure_frame_visible
        #
        #   yield if block_given?
        #
        #   reset_frames_scroll_position(frame_chain_to_reset)
        #
        #   logger.info 'Switching back into top level frame...'
        #   driver.switch_to.default_content
        #   return unless original_frame_chain
        #   logger.info 'Switching back into original frame...'
        #   driver.switch_to.frames frame_chain: original_frame_chain
        # end

        # Takes a snapshot of the application under test and matches it with the expected output.
        #
        # @param [String] tag An optional tag to be assosiated with the snapshot.
        # @param [Fixnum] match_timeout The amount of time to retry matching (seconds)
        # def check_window(tag = nil, match_timeout = USE_DEFAULT_MATCH_TIMEOUT)
        def check_window(*args)
          if disabled?
            Applitools::EyesLogger.logger.info "#{__method__} Ignore disabled"
            return
          end
          name, target = check_window_target(args)
          internal_check("#{__method__}(#{name})", target)
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
          if disabled?
            Applitools::EyesLogger.logger.info "#{__method__} Ignore disabled"
            return
          end
          name, target = check_region_target(args)
          internal_check("#{__method__}(#{name})", target)
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
          if disabled?
            Applitools::EyesLogger.logger.info "#{__method__} Ignore disabled"
            return
          end
          name, target = check_frame_target(options)
          internal_check("#{__method__}(#{name})", target)
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
          if disabled?
            Applitools::EyesLogger.logger.info "#{__method__} Ignore disabled"
            return
          end
          name, target = check_region_in_frame_target(options)
          internal_check("#{__method__}(#{name})", target)
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
        # def test(options = {}, &_block)
        #   open(options)
        #   yield(driver)
        #   close
        # ensure
        #   abort_if_not_closed
        # end


        # Takes a snapshot and matches it with the expected output.
        #
        # @param [String] name The name of the tag.
        # @param [Applitools::Selenium::Target] target which area of the window to check.
        # @return [Applitools::MatchResult] The match results.
        def check(*args)
          if disabled?
            Applitools::EyesLogger.logger.info "#{__method__} Ignore disabled"
            return
          end
          name, target = usual_check_target(args) # tag_for_debug = name
          internal_check("#{__method__}(#{name})", target)
        end


        private


        def check_region_target(args)
          options = { timeout: USE_DEFAULT_MATCH_TIMEOUT, tag: nil }.merge! Applitools::Utils.extract_options!(args)
          target = Applitools::Selenium::Target.new.region(*args).timeout(options[:match_timeout])
          target.fully if options[:stitch_content]
          Applitools::ArgumentGuard.is_a? target, 'target', Applitools::Selenium::Target
          [options[:tag], target]
        end

        def check_region_in_frame_target(args)
          options = { timeout: USE_DEFAULT_MATCH_TIMEOUT, tag: nil, stitch_content: false }.merge!(args)
          Applitools::ArgumentGuard.not_nil options[:by], 'options[:by]'
          Applitools::ArgumentGuard.is_a? options[:by], 'options[:by]', Array

          how_what = options.delete(:by)
          frame = options[:frame] || options[:frame_element] || options[:name_or_id]
          target = Applitools::Selenium::Target.new.timeout(options[:timeout])
          target.frame(frame) if frame
          target.fully if options[:stitch_content]
          target.region(*how_what)

          [options[:tag], target]
        end

        def check_frame_target(args)
          options = { timeout: USE_DEFAULT_MATCH_TIMEOUT, tag: nil }.merge!(args)
          frame = options[:frame] || options[:frame_element] || options[:name_or_id]
          target = Applitools::Selenium::Target.frame(frame).timeout(options[:timeout]).fully
          [options[:tag], target]
        end

        def check_window_target(args)
          tag = args.select { |a| a.is_a?(String) || a.is_a?(Symbol) }.first
          match_timeout = args.select { |a| a.is_a?(Integer) }.first
          fully = args.select { |a| a.is_a?(TrueClass) || a.is_a?(FalseClass) }.first
          fully = configuration.vg if fully.nil? # not vg ? force_full_page_screenshot

          target = Applitools::Selenium::Target.window
          target.timeout(match_timeout || USE_DEFAULT_MATCH_TIMEOUT)
          target.fully(fully)

          [tag, target]
        end

        def usual_check_target(args)
          args.compact!
          case (first_arg = args.shift)
            when String
              name = first_arg
              target = args.shift
            when Applitools::Selenium::Target
              target = first_arg
            when Hash
              target = first_arg[:target]
              name = first_arg[:name] || first_arg[:tag]
          end
          Applitools::ArgumentGuard.is_a? target, 'target', Applitools::Selenium::Target
          # configuration.appName # => "Eyes Selenium SDK - Fluent API"
          # configuration.testName # => "TestCheckFrame_Fluent_Scroll"
          target.fully(false) if target.to_socket_output[:fully].nil? && configuration.stitchMode === "Scroll" && !configuration.vg
          # target.fully(true) if target.to_socket_output[:fully].nil? && configuration.vg

          # require('pry')
          # binding.pry

          [name, target]
        end

        SELECTOR_NAME = "data-#{Applitools::UniversalClient::Refer::REF_ID}".freeze
        SCRIPT_STRING = "setApplitoolsDataId = function(e, id){e.setAttribute('#{SELECTOR_NAME}', id);};setApplitoolsDataId(arguments[0], arguments[1]);"

        # def set_element_selector_proc
        #   # adding custom attribute as a selector for universal server
        #   @set_element_selector_proc ||= Proc.new do |element|
        #     selector_val = element.attribute(SELECTOR_NAME)
        #     if selector_val.nil?
        #       selector_val = @refer.ref(element)[@refer.class::REF_ID]
        #       @driver.execute_script(SCRIPT_STRING, element, selector_val)
        #     end
        #     new_selector = "[#{SELECTOR_NAME}='#{selector_val}']"
        #     # puts new_selector
        #     new_selector_check = (@driver.find_element(css: new_selector) === element)
        #     raise Applitools::EyesDriverOperationException.new "Could not process #{element}" unless new_selector_check
        #     new_selector # { type: :css, selector: new_selector }
        #   end
        # end

        def internal_check(name, target)
          raise Applitools::EyesNotOpenException.new('Eyes not open!') if @eyes.nil?
          Applitools::EyesLogger.logger.info "#{configuration.testName} : #{name} started  ..."

          settings = normalize_check_settings(target)
          check_result = @eyes.check(settings)
          check_result_processing(check_result)
        end

        def normalize_check_settings(check_settings)
          _check_settings = Applitools::Utils::CheckSettings.new
          _check_settings.from(check_settings)
          # (check_settings, set_element_selector_proc)
          _check_settings.to_socket_output
        end

        def check_result_processing(check_result)
          if test_passed?(check_result)
            Applitools::EyesLogger.logger.info '--- Check passed'
          elsif server_error?(check_result)
            Applitools::EyesLogger.logger.info "#{configuration.testName} : --- Server Error"
            raise Applitools::EyesError.new(check_result[:message])
          elsif check_result === {} # NOTE : vg returns {} for ok and error !!! results at the close step
            Applitools::EyesLogger.logger.info '--- Check finished'
          else
            Applitools::EyesLogger.logger.info "#{configuration.testName} : --- Mistmatch!" # unless running_session.new_session?
          end
          Applitools::EyesLogger.logger.info "Done!"
          check_result
          #     not_aborted = !results['isAborted']
          #     new_and_saved = results['isNew'] && save_new_tests
          #     different_and_saved = results['isDifferent'] && save_failed_tests
          #     not_a_mismatch = !results['isDifferent'] && !results['isNew']
          # not_aborted && (new_and_saved || different_and_saved || not_a_mismatch)
        end

        def test_passed?(check_result)
          check_result === {asExpected: true}
        end

        def server_error?(check_result)
          check_result[:message] && check_result[:stack]
        end

      end
    end
  end
end
