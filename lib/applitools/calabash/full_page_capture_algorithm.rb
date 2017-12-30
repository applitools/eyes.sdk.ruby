Applitools::Calabash.require_dir 'calabash/full_page_capture_algorithm'

module Applitools
  module Calabash
    module FullPageCaptureAlgorithm
      ANDROID_ALGORITHMS = {
        'android.widget.ScrollView' => Applitools::Calabash::FullPageCaptureAlgorithm::AndroidScrollView
      }.freeze
      IOS_ALGORITHMS = {
        'UITableView' => Applitools::Calabash::FullPageCaptureAlgorithm::IosUITableView
      }.freeze
      class << self
        def get_algorithm_class(env, klass)
          case env
          when :ios
            IOS_ALGORITHMS[klass]
          when :android
            ANDROID_ALGORITHMS[klass]
          end
        end
      end
    end
  end
end
