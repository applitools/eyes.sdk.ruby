# frozen_string_literal: true

require 'oj'
module Applitools
  module Jsonable
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class << self
          attr_accessor :json_methods, :wrap_data_block
        end
        @json_methods = {}
        @wrap_data_block = nil
      end
    end

    module ClassMethods
      def json_field(*args)
        options = Applitools::Utils.extract_options!(args)
        field = args.first.to_sym
        options = { method: field }.merge! options
        json_methods[field] = options[:method]
        return unless options[:method].to_sym == field
        attr_accessor field
        ruby_style_field = Applitools::Utils.underscore(field.to_s)
        return if field.to_s == ruby_style_field
        define_method(ruby_style_field) do
          send(field)
        end
        define_method("#{ruby_style_field}=") do |v|
          send("#{field}=", v)
        end
      end

      def json_fields(*args)
        args.each { |m| json_field m }
      end

      def wrap_data(&block)
        @wrap_data_block = block
      end
    end

    def json_data
      result = self.class.json_methods.sort.map do |k,v|
        val = json_value(send(v))
        next if val.nil?
        [k, val]
      end.compact.to_h
      result = self.class.wrap_data_block.call(result) if self.class.wrap_data_block.is_a? Proc
      result
    end

    def json
      Oj.dump json_data
    end

    private

    def json_value(value)
      case value
      when Hash
        value.map { |k, v| [k, json_value(v)] }.sort { |a, b| a.first.to_s <=> b.first.to_s }.to_h
      when Array
        value.map { |el| json_value(el) }
      else
        value.respond_to?(:json_data) ? value.json_data : value
      end
    end
  end
end
