module Applitools::Selenium
  # @!visibility private
  class EyesStitchedElementScreenshot < Applitools::EyesScreenshot
    def initialize(*args)
      super(args.shift)
    end

    def sub_screenshot(*_args)
      self
    end
  end
end
