module Applitools
  class MatchWindowData
    class << self
      def convert_coordinates(region, screenshot)
        screenshot.convert_region_location(
          Applitools::Region.from_location_size(region.location, region.size),
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
              'MatchLevel' => 'None',
              'SplitTopHeight' => 0,
              'SplitBottomHeight' => 0,
              'IgnoreCaret' => false,
              'Ignore' => [],
              'Exact' => {
                'MinDiffIntensity' => 0,
                'MinDiffWidth' => 0,
                'MinDiffHeight' => 0,
                'MatchThreshold' => 0
              }
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
      @need_convert_ignored_regions_coordinates = false
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
      value.each do |i|
        current_data['UserInputs'] << i if self.class.valid_input(i)
      end
      current_data['Options']['UserInputs'] = current_data['UserInputs']
    end

    def ignored_regions=(value)
      Applitools::ArgumentGuard.is_a? value, 'value', Array
      value.each do |r|
        current_data['Options']['ImageMatchSettings']['Ignore'] << r.to_hash if self.class.valid_region(r)
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

    def read_target(target, driver)
      # options
      %w(trim).each do |field|
        send("#{field}=", target.options[field.to_sym])
      end
      # ignored regions
      target.ignored_regions.each do |r|
        case r
        when Proc
          region = r.call(driver)
          @ignored_regions << Applitools::Region.from_location_size(region.location, region.size)
          @need_convert_ignored_regions_coordinates = true
        when Applitools::Region
          @ignored_regions << r
          @need_convert_ignored_regions_coordinates = true
        end
      end
    end

    def ignore_mismatch
      current_data['IgnoreMismatch']
    end

    def tag
      current_data['Tag']
    end

    def trim=(value)
      current_data['Options']['Trim']['Enabled'] = value ? true : false
    end

    def convert_ignored_regions_coordinates
      return unless @need_convert_ignored_regions_coordinates
      self.ignored_regions = @ignored_regions.map do |r|
        self.class.convert_coordinates(r, app_output.screenshot)
      end
      @need_convert_ignored_regions_coordinates = false
    end

    def to_hash
      raise Applitools::EyesError.new(
        'You should convert coordinates for ignored_regions!'
      ) if @need_convert_ignored_regions_coordinates
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
