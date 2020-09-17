# frozen_string_literal: true

require 'applitools/selenium/stitch_modes'
require 'applitools/selenium/browsers_info'

module Applitools
  module Selenium
    class Configuration < Applitools::EyesBaseConfiguration
      DEFAULT_CONFIG = proc do
        {
          force_full_page_screenshot: false,
          wait_before_screenshots: 0.1,
          stitch_mode: Applitools::Selenium::StitchModes::CSS,
          hide_scrollbars: true,
          hide_caret: false,
          browsers_info: Applitools::Selenium::BrowsersInfo.new,
          rendering_grid_force_put: (ENV['APPLITOOLS_RENDERING_GRID_FORCE_PUT'] || 'false').casecmp('true') == 0,
          visual_grid_options: {}
        }
      end
      class << self
        def default_config
          super.merge DEFAULT_CONFIG.call
        end
      end

      boolean_field :force_full_page_screenshot
      int_field :wait_before_screenshots
      enum_field :stitch_mode, Applitools::Selenium::StitchModes.enum_values
      boolean_field :hide_scrollbars
      boolean_field :hide_caret
      boolean_field :send_dom

      object_field :browsers_info, Applitools::Selenium::BrowsersInfo
      int_field :concurrent_sessions
      boolean_field :rendering_grid_force_put
      object_field :visual_grid_options, Hash, true

      def custom_setter_for_visual_grid_options(value)
        return {} if value.nil?
        value
      end

      def add_browser(*args)
        case args.size
        when 0
          browser = Applitools::Selenium::DesktopBrowserInfo.new
        when 1
          b = args[0]
          raise(
            Applitools::EyesIllegalArgument,
            'Expected :browser to be an IRenderBrowserInfo instance!'
          ) unless b.is_a? IRenderBrowserInfo
          browser = b
        when 3
          browser = Applitools::Selenium::DesktopBrowserInfo.new.tap do |bi|
            bi.viewport_size = Applitools::RectangleSize.new(args[0], args[1])
            bi.browser_type = args[2]
          end
        end
        yield(Applitools::Selenium::RenderBrowserInfoFluent.new(browser)) if block_given?
        browsers_info.add browser
        # self.viewport_size = browser.viewport_size unless viewport_size
        self
      end

      def add_browsers(*browsers)
        browsers = case browsers.first
                     when Applitools::Selenium::IRenderBrowserInfo
                       browsers
                     when Array
                       browsers.first
                   end
        browsers.each do |browser|
          add_browser(browser)
        end
        self
      end

      def add_device_emulation(device_name, orientation = Orientations::PORTRAIT)
        Applitools::ArgumentGuard.not_nil device_name, 'device_name'
        raise Applitools::EyesIllegalArgument, 'Wrong device name!' unless Devices.enum_values.include? device_name
        emu = Applitools::Selenium::ChromeEmulationInfo.new(device_name, orientation)
        add_browser emu
      end

      def viewport_size
        user_defined_vp = super
        user_defined_vp = nil if user_defined_vp.respond_to?(:square) && user_defined_vp.square == 0
        return user_defined_vp if user_defined_vp
        from_browsers_info = browsers_info.select { |bi| bi.viewport_size.square > 0 }.first
        return from_browsers_info.viewport_size if from_browsers_info
        nil
      end

    end
  end
end
