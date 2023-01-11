# frozen_string_literal: true

module Applitools
  class MatchWindowData
    class << self
      def convert_coordinates(region, screenshot)
        return region.with_padding.to_hash if region.respond_to?(:converted?) && region.converted?
        screenshot.convert_region_location(
          region.with_padding,
          Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative],
          Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
        ).to_hash
      end

      def default_data
        {
          'IgnoreMismatch' => false,
          'MismatchWait' => 0,
          'Options' => {
            'Name' => nil,
            'UserInputs' => [],
            'IgnoreExpectedOutputSettings' => false,
            'ForceMatch' => false,
            'ForceMismatch' => false,
            'IgnoreMatch' => false,
            'IgnoreMismatch' => false,
            'ReplaceLast' => false,
            'Trim' => {
              'Enabled' => false
            },
            'RenderId' => ''
          },
          'Id' => nil,
          'UserInputs' => [],
          'AppOutput' => {
            'Screenshot64' => nil,
            'ScreenshotUrl' => nil,
            'Title' => nil,
            'IsPrimary' => false,
            'Elapsed' => 0,
            'Location' => {
              'X' => 0,
              'Y' => 0
            }
          },
          'Tag' => nil,
          'RenderId' => ''
        }
      end

      def valid_region(_r)
        true
      end

      def valid_input(_i)
        true
      end
    end

    attr_accessor :app_output, :user_inputs, :tag, :options, :ignore_mismatch, :default_image_match_settings

    def initialize(default_image_match_settings = nil)
      @app_output = nil
      @ignored_regions = []
      @floating_regions = []
      @need_convert_ignored_regions_coordinates = false
      @need_convert_floating_regions_coordinates = false
      @need_convert_strict_regions_coordinates = false
      @need_convert_content_regions_coordinates = false
      @need_convert_layout_regions_coordinates = false
      @need_convert_accessibility_regions_coordinates = false
      self.default_image_match_settings = default_image_match_settings.nil? ? Applitools::ImageMatchSettings.new : default_image_match_settings.deep_dup
    end

    def screenshot
      return '' unless app_output.screenshot.respond_to?(:image)
      app_output.screenshot.image.to_blob
    end

    def ignore_mismatch=(value)
      current_data['IgnoreMismatch'] = value ? true : false
      current_data['Options']['IgnoreMismatch'] = current_data['IgnoreMismatch']
    end

    def tag=(value)
      current_data['Tag'] = value
      current_data['Options']['Name'] = value
    end

    def variation_group_id=(value)
      current_data['Options']['variantId'] = value
    end

    def user_inputs=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Array
      current_data['UserInputs'] += value.select { |i| i.respond_to? :to_hash }
                                         .select { |i| self.class.valid_input(i) }.map(&:to_hash)
      current_data['Options']['UserInputs'] = current_data['UserInputs']
    end

    def ignored_regions=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Array
      value.each do |r|
        # current_data['Options']['ImageMatchSettings']['Ignore'] << r.to_hash if self.class.valid_region(r)
        default_image_match_settings.ignore << r.to_hash if self.class.valid_region(r)
      end
    end

    def floating_regions=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Array
      value.each do |r|
        default_image_match_settings.floating << r.to_hash
      end
    end

    def layout_regions=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Array
      value.each do |r|
        default_image_match_settings.layout << r.to_hash if self.class.valid_region(r)
      end
    end

    def strict_regions=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Array
      value.each do |r|
        default_image_match_settings.strict << r.to_hash if self.class.valid_region(r)
      end
    end

    def content_regions=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Array
      value.each do |r|
        default_image_match_settings.content << r.to_hash if self.class.valid_region(r)
      end
    end

    def accessibility_regions=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Array
      value.each do |r|
        default_image_match_settings.accessibility << r.to_hash if self.class.valid_region(r)
      end
    end

    def app_output=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Applitools::AppOutputWithScreenshot
      @app_output = value
      hash_value = Applitools::Utils.capitalize_hash_keys(value.to_hash)
      [:Screenshot64, :ScreenshotUrl, :Title, :IsPrimary, :Elapsed, :Location, :DomUrl, :VisualViewport].each do |key|
        next if hash_value[key].nil?
        current_data['AppOutput'][key.to_s] = case hash_value[key]
                                              when Hash
                                                Hash[hash_value[key].map { |k, v| [k.to_s, v] }]
                                              else
                                                hash_value[key]
                                              end
      end
    end

    def match_level=(value)
      default_image_match_settings.match_level = value
    end

    def match_level
      default_image_match_settings.match_level
    end

    def scale=(value)
      default_image_match_settings.scale = value
    end

    def scale
      default_image_match_settings.scale
    end

    def remainder=(value)
      default_image_match_settings.remainder = value
    end

    def remainder
      default_image_match_settings.remainder
    end

    def exact
      default_image_match_settings.exact
    end

    def use_dom
      default_image_match_settings.use_dom
    end

    def use_dom=(value)
      default_image_match_settings.use_dom = value
    end

    def enable_patterns
      default_image_match_settings.enable_patterns
    end

    def enable_patterns=(value)
      default_image_match_settings.enable_patterns = value
    end

    def ignore_displacements
      default_image_match_settings.ignore_displacements
    end

    def ignore_displacements=(value)
      default_image_match_settings.ignore_displacements = value
    end

    def render_id
      current_data['Options']['RenderId']
    end

    def render_id=(value)
      current_data['Options']['RenderId'] = value
      current_data['RenderId'] = value
    end

    def exact=(value)
      Applitools::ArgumentGuard.is_a?(value, 'value', Applitools::ImageMatchSettings::Exact)
      default_image_match_settings.exact = value
    end

    def read_target(target, driver)
      # options
      target_options_to_read.each do |field|
        a_value = target.options[field.to_sym]
        send("#{field}=", a_value) unless a_value.nil?
      end
      # ignored regions
      if target.respond_to? :ignored_regions
        @ignored_regions = obtain_regions_coordinates(target.ignored_regions, driver)
        @need_convert_ignored_regions_coordinates = true unless @ignored_regions.empty?
      end

      # floating regions
      return unless target.respond_to? :floating_regions
      target.floating_regions.each do |r|
        case r
        when Proc
          region = r.call(driver)
          raise Applitools::EyesError.new "Wrong floating region: #{region.class}" unless
              region.is_a? Applitools::FloatingRegion
          @floating_regions << region
          @need_convert_floating_regions_coordinates = true
        when Applitools::FloatingRegion
          @floating_regions << r
          @need_convert_floating_regions_coordinates = true
        end
      end

      # Layout regions
      if target.respond_to? :layout_regions
        @layout_regions = obtain_regions_coordinates(target.layout_regions, driver)
        @need_convert_layout_regions_coordinates = true unless @layout_regions.empty?
      end

      # Strict regions
      if target.respond_to? :strict_regions
        @strict_regions = obtain_regions_coordinates(target.strict_regions, driver)
        @need_convert_strict_regions_coordinates = true unless @strict_regions.empty?
      end

      # Content regions
      if target.respond_to? :content_regions
        @content_regions = obtain_regions_coordinates(target.content_regions, driver)
        @need_convert_content_regions_coordinates = true unless @content_regions.empty?
      end

      if target.respond_to? :accessibility_regions
        @accessibility_regions = obtain_accessibility_regions_coordinates(target.accessibility_regions, driver)
        @need_convert_accessibility_regions_coordinates = true unless @accessibility_regions.empty?
      end
      target
    end

    def obtain_accessibility_regions_coordinates(regions, driver)
      result = []
      regions.each do |r|
        case r
        when Proc
          region_or_regions = r.call(driver)
          case region_or_regions
          when Array
            result.concat(region_or_regions)
          when Applitools::AccessibilityRegion
            result << region_or_regions
          end
        else
          raise Applitools::EyesError, 'Error getting accessibility_regions coordinates'
        end
      end
      result
    end

    def obtain_regions_coordinates(regions, driver)
      result = []
      regions.each do |r|
        case r
        when Proc
          region = r.call(driver)
          result << Applitools::Region.from_location_size(region.location, region.size)
        when Applitools::Region
          result << r
        end
      end
      result
    end

    def target_options_to_read
      %w(trim ignore_caret match_level ignore_mismatch exact use_dom enable_patterns ignore_displacements)
    end

    private :target_options_to_read

    def ignore_mismatch
      current_data['IgnoreMismatch']
    end

    def replace_last
      current_data['Options']['ReplaceLast']
    end

    def replace_last=(value)
      Applitools::ArgumentGuard.one_of?(value, 'value', [TrueClass, FalseClass])
      current_data['Options']['ReplaceLast'] = value
    end

    def tag
      current_data['Tag']
    end

    def trim=(value)
      current_data['Options']['Trim']['Enabled'] = value ? true : false
    end

    def ignore_caret=(value)
      default_image_match_settings.ignore_caret = value
    end

    def accessibility_validation
      default_image_match_settings.accessibility_level
    end

    def accessibility_validation=(value)
      default_image_match_settings.accessibility_level = value
    end

    def convert_ignored_regions_coordinates
      return unless @need_convert_ignored_regions_coordinates
      self.ignored_regions = convert_regions_coordinates(@ignored_regions)
      @need_convert_ignored_regions_coordinates = false
    end

    def convert_layout_regions_coordinates
      return unless @need_convert_layout_regions_coordinates
      self.layout_regions = convert_regions_coordinates(@layout_regions)
      @need_convert_layout_regions_coordinates = false
    end

    def convert_strict_regions_coordinates
      return unless @need_convert_strict_regions_coordinates
      self.strict_regions = convert_regions_coordinates(@strict_regions)
      @need_convert_strict_regions_coordinates = false
    end

    def convert_content_regions_coordinates
      return unless @need_convert_content_regions_coordinates
      self.content_regions = convert_regions_coordinates(@content_regions)
      @need_convert_content_regions_coordinates = false
    end

    def convert_accessibility_regions_coordinates
      return unless @need_convert_accessibility_regions_coordinates
      self.accessibility_regions = convert_regions_coordinates(@accessibility_regions)
      @need_convert_accessibility_regions_coordinates = false
    end

    def convert_regions_coordinates(regions)
      regions.dup.map { |r| self.class.convert_coordinates(r, app_output.screenshot) } unless app_output.screenshot.nil?
    end

    def convert_floating_regions_coordinates
      return unless @need_convert_floating_regions_coordinates
      unless app_output.screenshot.nil?
        self.floating_regions = @floating_regions.map do |r|
          updated_region = app_output.screenshot.convert_region_location(
            r,
            Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative],
            Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
          )

          Applitools::FloatingRegion.new(
            updated_region.left,
            updated_region.top,
            updated_region.width,
            updated_region.height,
            r.max_left_offset,
            r.max_top_offset,
            r.max_right_offset,
            r.max_bottom_offset
          ).padding(r.current_padding)
        end
      end
      @need_convert_floating_regions_coordinates = false
    end

    def to_hash
      if @need_convert_accessibility_regions_coordinates
        raise Applitools::EyesError.new(
          'You should convert coordinates for content_regions!'
        )
      end

      if @need_convert_content_regions_coordinates
        raise Applitools::EyesError.new(
          'You should convert coordinates for content_regions!'
        )
      end

      if @need_convert_strict_regions_coordinates
        raise Applitools::EyesError.new(
          'You should convert coordinates for strict_regions!'
        )
      end

      if @need_convert_layout_regions_coordinates
        raise Applitools::EyesError.new(
          'You should convert coordinates for layout_regions!'
        )
      end

      if @need_convert_ignored_regions_coordinates
        raise Applitools::EyesError.new(
          'You should convert coordinates for ignored_regions!'
        )
      end

      if @need_convert_floating_regions_coordinates
        raise Applitools::EyesError.new(
          'You should convert coordinates for floating_regions!'
        )
      end
      result = current_data.dup
      result['Options']['ImageMatchSettings'] = default_image_match_settings.json_data
      result
    end

    def to_s
      to_hash
    end

    private

    def current_data
      @current_data ||= self.class.default_data
    end
  end
end
