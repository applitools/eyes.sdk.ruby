# frozen_string_literal: false

class Applitools::Appium::Eyes < Applitools::Selenium::SeleniumEyes
  def perform_driver_settings_for_appium_driver
    self.region_visibility_strategy = Applitools::Selenium::NopRegionVisibilityStrategy.new
    self.force_driver_resolution_as_viewport_size = true
  end

  def initialize(*args)
    super
    self.dont_get_title = true
    self.runner = Applitools::ClassicRunner.new
  end

  private :perform_driver_settings_for_appium_driver

  def check(*args)
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

    logger.info "check(#{name}) is called"
    self.tag_for_debug = name
    Applitools::ArgumentGuard.one_of? target, 'target', [Applitools::Selenium::Target, Applitools::Appium::Target]

    return check_native(name, target) if native_app?
    super
  end

  attr_accessor :eyes_element_to_check, :region_provider
  private :eyes_element_to_check, :eyes_element_to_check=, :region_provider, :region_provider=

  def check_native(name, target)
    logger.info "check_native(#{name}) is called"
    update_scaling_params
    target_to_check = target.finalize
    match_data = Applitools::MatchWindowData.new(default_match_settings)
    match_data.tag = name
    timeout = target_to_check.options[:timeout] || USE_DEFAULT_MATCH_TIMEOUT

    eyes_element = target_to_check.region_to_check.call(driver)
    self.eyes_element_to_check = eyes_element
    region_provider = Applitools::Appium::RegionProvider.new(driver, eyes_element)
    match_data.read_target(target_to_check, driver)

    check_window_base(
      region_provider, timeout, match_data
    )
  end

  def native_app?
    return true if driver.current_context == 'NATIVE_APP'
    false
  end

  def capture_screenshot
    logger.info 'Getting screenshot (capture_screenshot() has been invoked)'
    case eyes_element_to_check
    when Applitools::Region
      viewport_screenshot
    when Selenium::WebDriver::Element, Applitools::Selenium::Element
      element_screenshot
    end
  end

  def get_app_output_with_screenshot(*args)
    result = super do |screenshot|
      if scale_provider
        scaled_image = scale_provider.scale_image(screenshot.image)
        self.screenshot = Applitools::Appium::Screenshot.new(
          Applitools::Screenshot.from_image(
            case scaled_image
            when ChunkyPNG::Image
              scaled_image
            when Applitools::Screenshot::Datastream
              scaled_image.image
            else
              raise Applitools::EyesError.new('Unknown image format after scale!')
            end
          )
        )
      end
    end
    self.screenshot_url = nil
    result
  end

  def dom_data
    {}
  end

  def check_window(tag = nil, match_timeout = USE_DEFAULT_MATCH_TIMEOUT)
    target = Applitools::Appium::Target.window.tap do |t|
      t.timeout(match_timeout)
    end
    check(tag, target)
  end

  def check_region(*args)
    options = { timeout: USE_DEFAULT_MATCH_TIMEOUT, tag: nil }.merge! Applitools::Utils.extract_options!(args)
    target = Applitools::Appium::Target.new.region(*args).timeout(options[:match_timeout])
    check(options[:tag], target)
  end

  private

  def viewport_screenshot
    logger.info 'Viewport screenshot requested...'
    self.screenshot = Applitools::Appium::Screenshot.new(
      Applitools::Screenshot.from_datastream(driver.screenshot_as(:png))
    )
  end

  def element_screenshot
    logger.info 'Element screenshot requested...'
    self.screenshot = Applitools::Appium::Screenshot.new(
      Applitools::Screenshot.from_datastream(
        driver.element_screenshot_as(eyes_element_to_check, :png)
      )
    )
  end
end
