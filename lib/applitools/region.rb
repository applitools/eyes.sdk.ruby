module Applitools
  class Region
    def initialize(left, top, width, height)
      @left = left
      @top = top
      @width = width
      @height = height
    end

    def to_socket_output
      {
        left: @left,
        top: @top,
        width: @width,
        height: @height
      }
    end
  end
end
