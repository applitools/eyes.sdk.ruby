# frozen_string_literal: true

module Applitools
  class Enumerator < ::Enumerator
    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
      attr_reader :size
      def initialize(*args)
        @size = args[0] if args.size == 1
        super()
      end
    end
  end
end

module Applitools::ChunkyPNG
  module Resampling
    def resample_bicubic!(dst_width, dst_height)
      new_pixels = resampling_first_step(dst_width, dst_height)
      replace_canvas!(dst_width, dst_height, new_pixels)
      self
    end

    def resample_bicubic(new_width, new_height)
      dup.resample_bicubic!(new_width, new_height)
    end

    def bicubic_x_points(dst_width)
      bicubic_points2(width, dst_width, false)
    end

    def bicubic_y_points(dst_height)
      bicubic_points2(height, dst_height, true)
    end

    def line_with_bounds(y, src_dimension, direction)
      line = (direction ? column(y) : row(y))
      [imaginable_point(line[0], line[1])] + line + [
        imaginable_point(line[src_dimension - 2], line[src_dimension - 3]),
        imaginable_point(line[src_dimension - 1], line[src_dimension - 2])
      ]
    end

    def imaginable_point(point1, point2)
      r = [0, [255, ChunkyPNG::Color.r(point1) << 1].min - ChunkyPNG::Color.r(point2)].max
      g = [0, [255, ChunkyPNG::Color.g(point1) << 1].min - ChunkyPNG::Color.g(point2)].max
      b = [0, [255, ChunkyPNG::Color.b(point1) << 1].min - ChunkyPNG::Color.b(point2)].max
      a = [0, [255, ChunkyPNG::Color.a(point1) << 1].min - ChunkyPNG::Color.a(point2)].max
      ChunkyPNG::Color.rgba(r, g, b, a)
    end
  end
end
