module Applitools
  class RectangleSize
    def initialize(width, height)
      @width = width
      @height = height
    end

    def to_socket_output
      {
        width: @width,
        height: @height
      }
    end
  end
end
