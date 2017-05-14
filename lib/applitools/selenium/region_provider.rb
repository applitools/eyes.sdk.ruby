module Applitools::Selenium
  class RegionProvider
    # Do we need it under Selenium module?
    attr_reader :region, :coordinate_type
    def initialize(region, coordinate_type)
      @region = region
      @coordinate_type = coordinate_type
    end
  end
end
