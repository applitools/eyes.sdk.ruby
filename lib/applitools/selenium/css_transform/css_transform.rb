# frozen_string_literal: true

module Applitools
  module CssTransform
    private

    def get_position_from_transform(transform)
      regexp = /^translate\(\s*(\-?)([\d, \.]+)px,\s*(\-?)([\d, \.]+)px\s*\)/
      data = regexp.match(transform)

      raise Applitools::EyesError.new "Can't parse CSS transition: #{transform}!" unless data
      x = data[2].to_f.round
      y = data[4].to_f.round

      x *= -1 unless data[1].empty?
      y *= -1 unless data[3].empty?

      Applitools::Location.new(x, y)
    end
  end
end
