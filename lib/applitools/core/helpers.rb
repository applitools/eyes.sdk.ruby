# frozen_string_literal: true

module Applitools
  module Helpers
    @environment_variables = {}

    def self.environment_variables
      @environment_variables
    end

    def abstract_attr_accessor(*names)
      names.each do |method_name|
        instance_variable_set "@#{method_name}", nil
        abstract_method method_name, true
        abstract_method "#{method_name}=", true
      end
    end

    def abstract_method(method_name, is_private = true)
      define_method method_name do |*_args|
        raise Applitools::AbstractMethodCalled.new method_name, self
      end
      private method_name if is_private
    end

    def environment_attribute(attribute_name, environment_variable)
      class_eval do
        Applitools::Helpers.environment_variables[environment_variable.to_sym] = ENV[environment_variable.to_s] if
            ENV[environment_variable.to_s]
        attr_accessor attribute_name
        define_method(attribute_name) do
          current_value = instance_variable_get "@#{attribute_name}".to_sym
          return current_value if current_value
          instance_variable_set(
            "@#{attribute_name}".to_sym,
            Applitools::Helpers.environment_variables[environment_variable.to_sym]
          )
        end
      end
    end
  end
end
