# frozen_string_literal: true

require_relative 'region'
module Applitools
  class FloatingRegion < Region
    class << self
      def any(element, *args)
        case element
        when Applitools::Region
          for_element(element, *args)
        when ::Selenium::WebDriver::Element
          for_element(Applitools::Region.from_location_size(element.location, element.size), *args)
        when Applitools::Selenium::Element
          for_element(element.bounds, *args)
        else
          raise Applitools::EyesIllegalArgument.new "Unsupported element - #{element.class}"
        end
      end

      def for_element(element, *args)
        case args.count
        when 1
          new element, args.first
        when 4
          new element, FloatingBounds.new(*args)
        else
          raise(
            Applitools::EyesIllegalArgument,
            'Applitools::FloatingRegion.for_element has been called with illegal argument'
          )
        end
      end
      private :for_element
    end

    attr_accessor :max_top_offset, :max_right_offset, :max_bottom_offset, :max_left_offset

    NAMES = [
      :left, :top, :width, :height, :max_left_offset, :max_top_offset, :max_right_offset, :max_bottom_offset
    ].freeze

    def initialize(*args)
      case args.size
      when 2
        region = args.first
        bounds = args.last
        super(region.left, region.top, region.width, region.height)
        self.max_left_offset = bounds.max_left_offset
        self.max_top_offset = bounds.max_top_offset
        self.max_right_offset = bounds.max_right_offset
        self.max_bottom_offset = bounds.max_bottom_offset
      when 8
        args.each_with_index do |a, i|
          Applitools::ArgumentGuard.is_a? a, NAMES[i], Integer
          Applitools::ArgumentGuard.greater_than_or_equal_to_zero(a, NAMES[i])
        end
        super(*args[0..3])
        self.max_left_offset = args[4]
        self.max_top_offset = args[5]
        self.max_right_offset = args[6]
        self.max_bottom_offset = args[7]
      else
        raise(
          Applitools::EyesIllegalArgument,
          'Expected Applitools::FloatingRegion.new to be called as ' \
             'Applitools::FloatingRegion.new(region, floating_bounds)' \
             'or ' \
             'Applitools::FloatingRegion.new(left, top, width, height, ' \
             'bounds_leeft, bounds_top, bounds_right, bounds_bottom)'
        )
      end
    end

    def scale_it!(scale_factor)
      self.left *= scale_factor
      self.top *= scale_factor
      self.width *= scale_factor
      self.height *= scale_factor
      self.max_left_offset *= scale_factor
      self.max_top_offset *= scale_factor
      self.max_right_offset *= scale_factor
      self.max_bottom_offset *= scale_factor
      self
    end

    def to_hash
      {
        'Top' => top,
        'Left' => left,
        'Width' => width,
        'Height' => height,
        'MaxUpOffset' => max_top_offset + padding_top,
        'MaxLeftOffset' => max_left_offset + padding_left,
        'MaxRightOffset' => max_right_offset + padding_right,
        'MaxDownOffset' => max_bottom_offset + padding_bottom
      }
    end
  end

  class FloatingBounds
    attr_accessor :max_left_offset, :max_top_offset, :max_right_offset, :max_bottom_offset
    def initialize(max_left_offset, max_top_offset, max_right_offset, max_bottom_offset)
      Applitools::ArgumentGuard.is_a?(max_left_offset, 'max_left_offset', Integer)
      Applitools::ArgumentGuard.is_a?(max_top_offset, 'max_top_offset', Integer)
      Applitools::ArgumentGuard.is_a?(max_right_offset, 'max_right_offset', Integer)
      Applitools::ArgumentGuard.is_a?(max_bottom_offset, 'max_bottom_offset', Integer)

      Applitools::ArgumentGuard.greater_than_or_equal_to_zero(max_left_offset, 'max_left_offset')
      Applitools::ArgumentGuard.greater_than_or_equal_to_zero(max_top_offset, 'max_top_offset')
      Applitools::ArgumentGuard.greater_than_or_equal_to_zero(max_right_offset, 'max_right_offset')
      Applitools::ArgumentGuard.greater_than_or_equal_to_zero(max_bottom_offset, 'max_bottom_offset')

      self.max_left_offset = max_left_offset
      self.max_top_offset = max_top_offset
      self.max_right_offset = max_right_offset
      self.max_bottom_offset = max_bottom_offset
    end
  end
end
