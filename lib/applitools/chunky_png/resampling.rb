module Applitools::ChunkyPNG
  module Resampling
    def resample_bicubic!(dst_width, dst_height)
      w_m = [1, width / dst_width].max
      h_m = [1, height / dst_height].max

      dst_width2 = dst_width * w_m
      dst_height2 = dst_height * h_m

      pixels = bicubic_x_points(dst_width2)
      replace_canvas!(dst_width2, height, pixels)

      pixels = bicubic_y_points(dst_height2)
      replace_canvas!(dst_width2, dst_height2, pixels)

      return self unless w_m * h_m > 1

      pixels = scale_points2(dst_width, dst_height, w_m, h_m)
      replace_canvas!(dst_width, dst_height, pixels)
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
