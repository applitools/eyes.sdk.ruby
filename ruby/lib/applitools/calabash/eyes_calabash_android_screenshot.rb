# frozen_string_literal: true

require_relative 'eyes_calabash_screenshot'
module Applitools
  module Calabash
    class EyesCalabashAndroidScreenshot < ::Applitools::Calabash::EyesCalabashScreenshot
      extend Forwardable
      def_delegators 'Applitools::EyesLogger', :logger

      ANDROID_DENSITY = {
        120 => 0.75,
        160 => 1,
        213 => 1.33,
        240 => 1.5,
        320 => 2,
        480 => 3,
        560 => 3.5,
        640 => 4
      }.freeze

      DENSITY_DEFAULT = 160

      class UnknownDeviceDensity < ::Applitools::EyesError; end

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
        logger.warn("Trying to set unknown device density - #{value}") unless
            ANDROID_DENSITY.keys.include?(value.to_i)
        @scale_factor = value.to_f / DENSITY_DEFAULT
      end
    end
  end
end
