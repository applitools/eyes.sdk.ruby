# frozen_string_literal: true

module Applitools
  module Calabash
    class Target
      include Applitools::FluentInterface

      attr_accessor :options, :ignored_regions, :region_to_check, :floating_regions

      def initialize
        self.ignored_regions = []
        self.floating_regions = []
        self.options = {
          trim: false
        }
      end

      def fully
        options[:stitch_content] = true
        self
      end

      def ignore(region = nil)
        if region
          Applitools::ArgumentGuard.is_a? region, 'region', Applitools::Calabash::CalabashElement
          ignored_regions << region.region
        else
          self.ignored_regions = []
        end
        self
      end

      def region(region = nil)
        if region
          case region
          when Applitools::Calabash::CalabashElement, Applitools::Region
            self.region_to_check = region
          else
            self.region_to_check = nil
            raise(
              Applitools::EyesIllegalArgument,
              'Expected region to be instance of Applitools::Calabash::CalabashElement or Applitools::Region'
            )
          end
        else
          self.region_to_check = nil
        end
        self
      end

      # def floating(*args)
      #   value = case args.first
      #             when Applitools::FloatingRegion
      #               proc { args.first.scale_it!(scale_factor) }
      #             when Applitools::Region
      #               proc do
      #                 region = args.shift
      #                 region.scale_it!(scale_factor)
      #                 Applitools::FloatingRegion.new region.left, region.top, region.width, region.height, *args
      #               end
      #             else
      #               self.floating_regions = []
      #           end
      #   floating_regions << value
      #   self
      # end
    end
  end
end
