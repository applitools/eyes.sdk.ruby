require_relative 'match_level_setter'
module Applitools::FluentInterface
  include Applitools::MatchLevelSetter

  def self.included(base)
    base.define_singleton_method(:===) do |other|
      return name == other if other.is_a? String
      super(other)
    end
  end

  def ignore_caret(value = false)
    options[:ignore_caret] = value ? true : false
    self
  end

  def timeout(value)
    options[:timeout] = value.to_i
    self
  end

  def trim(value = true)
    options[:trim] = value ? true : false
    self
  end

  def ignore_mismatch(value)
    options[:ignore_mismatch] = value ? true : false
    self
  end

  # Sets match_level for current test
  # @param [Symbol] value Can be one of allowed match levels - :none, :layout, :layout2, :content, :strict or :exact
  # @param [Hash] exact_options exact options are used only for :exact match level
  # @option exact_options [Integer] :min_diff_intensity
  # @option exact_options [Integer] :min_diff_width
  # @option exact_options [Integer] :min_diff_height
  # @option exact_options [Integer] :match_threshold
  # @return [Target] Applitools::Selenium::Target or Applitools::Images::target

  def match_level(value, exact_options = {})
    options[:match_level], options[:exact] = match_level_with_exact(value, exact_options)
    self
  end
end
