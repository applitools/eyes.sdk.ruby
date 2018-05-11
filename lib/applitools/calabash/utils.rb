# frozen_string_literal: true

module Applitools
  module Calabash
    module Utils
      extend self

      def create_directories(eyes_settings)
        FileUtils.mkpath(
          File.join(Dir.getwd, eyes_settings.tmp_dir, eyes_settings.screenshot_dir)
        )
        FileUtils.mkpath(
          File.join(Dir.getwd, eyes_settings.log_dir)
        )
      end

      def clear_directories(eyes_settings)
        tmp_dir = File.join Dir.getwd, eyes_settings.tmp_dir
        log_dir = File.join Dir.getwd, eyes_settings.log_dir

        FileUtils.remove_dir(tmp_dir) if File.exist?(tmp_dir)
        FileUtils.remove_dir(log_dir) if File.exist?(log_dir)
      end

      def using_screenshot(context)
        return unless block_given?
        screenshot_options = Applitools::Calabash::EyesSettings.instance.screenshot_names.next
        yield context.screenshot(screenshot_options)
      end

      def region_from_element(element)
        region = Applitools::Region.new(
          element['rect']['x'],
          element['rect']['y'],
          element['rect']['width'],
          element['rect']['height']
        )
        return region if Applitools::Calabash::EnvironmentDetector.android?
        region.scale_it!(Applitools::Calabash::EyesSettings.instance.eyes.density)
      end

      def request_element(context, element, method)
        Applitools::ArgumentGuard.is_a?(element, 'element', Applitools::Calabash::CalabashElement)
        context.query(element.element_query, method)
      end

      def grub_android_class_name(context, element)
        request_element(context, element, :class)
      end

      def grub_ios_class_name(context, element)
        request_element(context, element, :className)
      end

      def get_android_element(context, query, index)
        element_query = if (id = context.query(query, :getId)[index.to_i]) && id > 0
                          "* id:#{id}"
                        else
                          query + " index:#{index.to_i}"
                        end
        element = context.query(element_query).first
        Applitools::Calabash::CalabashElement.new(element, element_query)
      end

      def get_ios_element(context, query, index)
        hash = context.query(query, :hash)[index.to_i]
        return unless hash
        element_query = "* hash:#{hash}"
        element = context.query(element_query).first
        Applitools::Calabash::CalabashElement.new(element, element_query)
      end
    end
  end
end
