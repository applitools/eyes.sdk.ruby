# frozen_string_literal: true

module Applitools
  class MatchWindowData
    class << self
      def convert_coordinates(region, screenshot)
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
            'ImageMatchSettings' => {
              'MatchLevel' => 'Strict',
              'SplitTopHeight' => 0,
              'SplitBottomHeight' => 0,
              'IgnoreCaret' => true,
              'Ignore' => [],
              'Floating' => [],
              'Exact' => {
                'MinDiffIntensity' => 0,
                'MinDiffWidth' => 0,
                'MinDiffHeight' => 0,
                'MatchThreshold' => 0
              },
              'scale' => 0,
              'remainder' => 0
            },
            'IgnoreExpectedOutputSettings' => false,
            'ForceMatch' => false,
            'ForceMismatch' => false,
            'IgnoreMatch' => false,
            'IgnoreMismatch' => false,
            'Trim' => {
              'Enabled' => false
            }
          },
          'Id' => nil,
          'UserInputs' => [],
          'AppOutput' => {
            'Screenshot64' => nil,
            'ScreenshotUrl' => nil,
            'Title' => nil,
            'IsPrimary' => false,
            'Elapsed' => 0
          },
          'Tag' => nil
        }
      end

      def valid_region(_r)
        true
      end

      def valid_input(_i)
        true
      end
    end

    attr_accessor :app_output, :user_inputs, :tag, :options, :ignore_mismatch

    def initialize
      @app_output = nil
      @ignored_regions = []
      @floating_regions = []
      @need_convert_ignored_regions_coordinates = false
      @need_convert_floating_regions_coordinates = false
    end

    def screenshot
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

    def user_inputs=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Array
      current_data['UserInputs'] += value.select { |i| i.respond_to? :to_hash }
                                         .select { |i| self.class.valid_input(i) }.map(&:to_hash)
      current_data['Options']['UserInputs'] = current_data['UserInputs']
    end

    def ignored_regions=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Array
      value.each do |r|
        current_data['Options']['ImageMatchSettings']['Ignore'] << r.to_hash if self.class.valid_region(r)
      end
    end

    def floating_regions=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Array
      value.each do |r|
        current_data['Options']['ImageMatchSettings']['Floating'] << r.to_hash
      end
    end

    def app_output=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Applitools::AppOutputWithScreenshot
      @app_output = value
      hash_value = value.to_hash
      %w(Screenshot64 ScreenshotUrl Title IsPrimary Elapsed).each do |key|
        current_data['AppOutput'][key] = hash_value[key] unless hash_value[key].nil?
      end
    end

    def match_level=(value)
      current_data['Options']['ImageMatchSettings']['MatchLevel'] = value
    end

    def match_level
      current_data['Options']['ImageMatchSettings']['MatchLevel']
    end

    def scale=(value)
      current_data['Options']['ImageMatchSettings']['scale'] = value
    end

    def scale
      current_data['Options']['ImageMatchSettings']['scale']
    end

    def remainder=(value)
      current_data['Options']['ImageMatchSettings']['remainder'] = value
    end

    def remainder
      current_data['Options']['ImageMatchSettings']['remainder']
    end

    def exact
      current_data['Options']['ImageMatchSettings']['Exact']
    end

    def exact=(value)
      raise Applitools::EyesError.new('You should pass a hash as a value!') unless value.nil? || value.is_a?(Hash)
      return current_data['Options']['ImageMatchSettings']['Exact'] = nil if value.nil?
      current_value = exact || {}
      %w(MinDiffIntensity MinDiffWidth MinDiffHeight MatchThreshold).each do |k|
        current_value[k] = value[k]
      end
      current_data['Options']['ImageMatchSettings']['Exact'] = current_value
    end

    def read_target(target, driver)
      # options
      target_options_to_read.each do |field|
        a_value = target.options[field.to_sym]
        send("#{field}=", a_value) unless a_value.nil?
      end
      # ignored regions
      if target.respond_to? :ignored_regions
        target.ignored_regions.each do |r|
          case r
          when Proc
            @ignored_regions << r.call(driver)
            @need_convert_ignored_regions_coordinates = true
          when Applitools::Region
            @ignored_regions << r
            @need_convert_ignored_regions_coordinates = true
          end
        end
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
    end

    def target_options_to_read
      %w(trim ignore_caret match_level ignore_mismatch exact)
    end

    private :target_options_to_read

    def ignore_mismatch
      current_data['IgnoreMismatch']
    end

    def tag
      current_data['Tag']
    end

    def trim=(value)
      current_data['Options']['Trim']['Enabled'] = value ? true : false
    end

    def ignore_caret=(value)
      current_data['Options']['ImageMatchSettings']['IgnoreCaret'] = value
    end

    def convert_ignored_regions_coordinates
      return unless @need_convert_ignored_regions_coordinates
      self.ignored_regions = @ignored_regions.map do |r|
        self.class.convert_coordinates(r, app_output.screenshot)
      end
      @need_convert_ignored_regions_coordinates = false
    end

    def convert_floating_regions_coordinates
      return unless @need_convert_floating_regions_coordinates
      self.floating_regions = @floating_regions.map do |r|
        updated_region = app_output.screenshot.convert_region_location(
          r,
          Applitools::EyesScreenshot::COORDINATE_TYPES[:context_relative],
          Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
        )
        updated_region.to_hash
      end
      @need_convert_floating_regions_coordinates = false
    end

    def to_hash
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
      current_data.dup
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
