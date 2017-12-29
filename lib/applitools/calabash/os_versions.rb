module Applitools
  module Calabash
    module OsVersions
      module Android
        extend self
        API_TO_NAME = {
          4 => 'Android 1',
          10 => 'Android 2',
          13 => 'Android 3',
          20 => 'Android 4',
          22 => 'Android 5',
          23 => 'Android 6',
          25 => 'Android 7',
          27 => 'Android 8'
        }.freeze

        def os_version(api_level)
          API_TO_NAME[API_TO_NAME.keys.select { |v| api_level.to_i >= v }.last] || 'Android'
        end
      end
    end
  end
end
