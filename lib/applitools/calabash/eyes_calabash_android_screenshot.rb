# frozen_string_literal: true

require_relative 'eyes_calabash_screenshot'
module Applitools
  module Calabash
    class EyesCalabashAndroidScreenshot < ::Applitools::Calabash::EyesCalabashScreenshot
      ANDROID_DENSITY = {
        120 => 0.75,
        160 => 1,
        213 => 1.33,
        240 => 1.5,
        320 => 2,
        480 => 3,
        640 => 4
      }.freeze

      def initialize(*args)
        options = if args.last.is_a? Hash
                    args.pop
                  else
                    {}
                  end
        super(*args)
        @scale_factor = nil
        self.density = options[:density] if options[:density]
        @scale_factor ||= options[:scale_factor]
        @scale_factor = 1 unless @scale_factor
      end

      def convert_region_location(region, from, to)
        case from
        when DRIVER
          case to
          when SCREENSHOT_AS_IS
            region
          else
            raise Applitools::EyesError, "from: #{from}, to: #{to}"
          end
        when CONTEXT_RELATIVE
          case to
          when SCREENSHOT_AS_IS
            region.scale_it!(1.to_f / scale_factor) # !!!!!!
            region
          else
            raise Applitools::EyesError, "from: #{from}, to: #{to}"
          end
        else
          raise Applitools::EyesError, "from: #{from}, to: #{to}"
        end
        region
      end

      def density=(value)
        raise Applitools::EyesIllegalArgument, "Unknown density = #{value}" unless ANDROID_DENSITY[value.to_i]
        @scale_factor = ANDROID_DENSITY[value.to_i]
      end
    end
  end
end
