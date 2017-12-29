require_relative 'eyes_calabash_screenshot'
module Applitools
  module Calabash
    class EyesCalabashIosScreenshot < Applitools::Calabash::EyesCalabashScreenshot
      def convert_region_location(region, from, to)
        case from
        when DRIVER
          case to
          when SCREENSHOT_AS_IS
            region.scale_it!(scale_factor)
          else
            raise Applitools::EyesError, "from: #{from}, to: #{to}"
          end
        when CONTEXT_RELATIVE
          case to
          when SCREENSHOT_AS_IS
            region
          else
            raise Applitools::EyesError, "from: #{from}, to: #{to}"
          end
        else
          raise Applitools::EyesError, "from: #{from}, to: #{to}"
        end
        region
      end
    end
  end
end
