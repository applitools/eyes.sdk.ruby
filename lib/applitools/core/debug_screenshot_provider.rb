# frozen_string_literal: true

require 'fileutils'

module Applitools
  class DebugScreenshotProvider
    attr_reader :debug_flag_getter, :debug_tag_getter
    attr_accessor :screenshot_dir
    def initialize(options = { screenshot_dir: 'debug_screenshots' })
      @screenshot_dir = options[:screenshot_dir]
    end

    def save(image, suffix = '')
      return unless debug
      case image
      when ::ChunkyPNG::Image, Applitools::Screenshot
        image.save(file_name_to_save(suffix)) if image.area > 0
      when Applitools::EyesScreenshot
        image.image.save(file_name_to_save(suffix)) if image.image.area > 0
      when String
        ::ChunkyPNG::Image.from_string(image).save(file_name_to_save(suffix))
      else
        return
      end
    end

    def save_subscreenshot(image, region)
      suffix = region.to_s + '__cropped'
      save(image, suffix)
    end

    def tag_access(&b)
      @debug_tag_getter = b
      self
    end

    def tag_for_debug
      return debug_tag_getter.call || '' if debug_tag_getter.is_a? Proc
      :''
    end

    def debug_flag_access(&b)
      @debug_flag_getter = b
      self
    end

    def debug
      return debug_flag_getter.call if debug_flag_getter.is_a? Proc
      false
    end

    private

    def file_name_to_save(suffix)
      File.join(
        screenshots_path,
        "#{prefix}__#{screenshot_names.next}#{suffix.empty? ? '' : '__' + suffix}.png"
      ).gsub(/\s+/, '_')
    end

    def screenshot_names
      @screenshot_name_enumerator ||= Enumerator.new do |y|
        counter = 1
        loop do
          y << format(
            '%s__%04d__%s',
            Time.now.strftime('%Y_%m_%d_%H_%M'),
            counter, tag_for_debug.empty? ? '' : tag_for_debug.gsub(/\s+/, '_')
          )
          counter += 1
        end
      end
    end

    def prefix
      :screenshot
    end

    def screenshots_path
      dir = File.join(Dir.pwd, screenshot_dir)
      FileUtils.mkdir_p(dir)
      dir
    end
  end
end
