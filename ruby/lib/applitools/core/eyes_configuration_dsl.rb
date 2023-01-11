# frozen_string_literal: true

module Applitools
  module EyesConfigurationDSL
    def methods_to_delegate
      @methods_to_delegate ||= []
    end

    def accessor_methods
      @accessor_methods ||= []
    end

    def collect_method(field_name)
      accessor_methods.push field_name.to_sym
      methods_to_delegate.push field_name.to_sym
      methods_to_delegate.push "#{field_name}=".to_sym
    end

    def boolean_field(field_name)
      collect_method field_name
      define_method(field_name) do
        return send("custom_getter_for_#{field_name}", config_hash[field_name.to_sym]) if
            respond_to?("custom_getter_for_#{field_name}")
        return nil if config_hash[field_name.to_sym].nil?
        return true if config_hash[field_name.to_sym]
        false
      end

      define_method("#{field_name}=") do |*args|
        value = args.shift
        config_hash[field_name.to_sym] = value ? true : false
        config_hash[field_name.to_sym] = send("custom_setter_for_#{field_name}", config_hash[field_name.to_sym]) if
            respond_to?("custom_setter_for_#{field_name}")
      end

      define_method("defined_#{field_name}?") do
        true
      end
    end

    def string_field(field_name)
      collect_method field_name
      define_method(field_name) do
        return send("custom_getter_for_#{field_name}", config_hash[field_name.to_sym]) if
            respond_to?("custom_getter_for_#{field_name}")
        config_hash[field_name.to_sym]
      end

      define_method("#{field_name}=") do |*args|
        value = args.shift
        unless value.is_a? String
          raise Applitools::EyesIllegalArgument, "Expected #{field_name} to be a String but got #{value.class} instead"
        end
        config_hash[field_name.to_sym] = value.freeze
        config_hash[field_name.to_sym] = send("custom_setter_for_#{field_name}", config_hash[field_name.to_sym]) if
            respond_to?("custom_setter_for_#{field_name}")
      end

      define_method("defined_#{field_name}?") do
        value = send(field_name)
        return false if value.nil?
        !value.empty?
      end
    end

    def object_field(field_name, klass, allow_nil = false)
      collect_method field_name
      define_method(field_name) do
        return send("custom_getter_for_#{field_name}", config_hash[field_name.to_sym]) if
            respond_to?("custom_getter_for_#{field_name}")
        config_hash[field_name.to_sym]
      end
      define_method("#{field_name}=") do |*args|
        value = args.shift
        unless value.is_a?(klass)
          raise(
            Applitools::EyesIllegalArgument,
            "Expected #{klass} but got #{value.class}"
          ) unless allow_nil && value.nil?
        end
        config_hash[field_name.to_sym] = value
        config_hash[field_name.to_sym] = send("custom_setter_for_#{field_name}", config_hash[field_name.to_sym]) if
            respond_to?("custom_setter_for_#{field_name}")
      end
      define_method("defined_#{field_name}?") do
        value = send(field_name)
        value.is_a? klass
      end
    end

    def int_field(field_name)
      collect_method(field_name)
      define_method(field_name) do
        return send("custom_getter_for_#{field_name}", config_hash[field_name.to_sym]) if
            respond_to?("custom_getter_for_#{field_name}")
        config_hash[field_name.to_sym]
      end

      define_method("#{field_name}=") do |*args|
        value = args.shift
        raise Applitools::EyesIllegalArgument, "Expected #{field_name} to be an Integer" unless value.respond_to?(:to_i)
        config_hash[field_name.to_sym] = value.to_i if value.respond_to? :to_i
        config_hash[field_name.to_sym] = send("custom_setter_for_#{field_name}", config_hash[field_name.to_sym]) if
            respond_to?("custom_setter_for_#{field_name}")
      end

      define_method("defined_#{field_name}?") do
        value = send(field_name)
        value.is_a? Integer
      end
    end

    def enum_field(field_name, available_values_array)
      collect_method(field_name)

      define_method(field_name) do
        return send("custom_getter_for_#{field_name}", config_hash[field_name.to_sym]) if
            respond_to?("custom_getter_for_#{field_name}")
        config_hash[field_name.to_sym]
      end

      define_method("#{field_name}=") do |*args|
        value = args.shift
        unless available_values_array.include? value
          raise(
            Applitools::EyesIllegalArgument,
            "Unknown #{field_name} #{value}. Allowed #{field_name} values: " \
           "#{available_values_array.join(', ')}"
          )
        end
        config_hash[field_name.to_sym] = value
        config_hash[field_name.to_sym] = send("custom_setter_for_#{field_name}", config_hash[field_name.to_sym]) if
            respond_to?("custom_setter_for_#{field_name}")
      end

      define_method("defined_#{field_name}?") do
        available_values_array.include? send(field_name)
      end
    end
  end
end
