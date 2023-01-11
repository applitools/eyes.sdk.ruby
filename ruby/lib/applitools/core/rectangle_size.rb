# frozen_string_literal: true

require_relative 'hash_extension'
module Applitools
  # rubocop:disable Metrics/BlockLength
  RectangleSize = Struct.new(:width, :height) do
    include Applitools::HashExtension
    class << self
      def from_any_argument(value)
        return from_string(value) if value.is_a? String
        return from_hash(value) if value.is_a? Hash
        return from_struct(value) if value.respond_to?(:width) & value.respond_to?(:height)
        return value if value.is_a? self
        nil
      end

      alias_method :for, :from_any_argument

      def from_string(value)
        width, height = value.split(/x/)
        new width.to_i, height.to_i
      end

      def from_hash(value)
        new value[:width].to_i, value[:height].to_i
      end

      def from_struct(value)
        new value.width.to_i, value.height.to_i
      end
    end

    def initialize(*args)
      super
      struct_define_to_h_method if respond_to? :struct_define_to_h_method
    end

    def to_s
      "#{width}x#{height}"
    end

    def -(other)
      self.width = width - other.width
      self.height = height - other.height
      self
    end

    def +(other)
      self.width = width + other.width
      self.height = height + other.height
      self
    end

    def scale_it!(scale_factor)
      self.width *= scale_factor
      self.height *= scale_factor
      self
    end

    def square
      return 0 if width.nil? || height.nil?
      width * height
    end

    def >(other)
      square > other.square
    end

    def<(other)
      square < other.square
    end

    def to_hash
      to_h
    end

    def empty?
      square.zero?
    end
  end
  # rubocop:enable Metrics/BlockLength
end
