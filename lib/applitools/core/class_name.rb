module Applitools
  class ClassName < String
    def ===(other)
      self == other.class.name
    end
  end
end
