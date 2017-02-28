module Served
  module Resource
    module Configurable
      extend ActiveSupport::Concern

      included do
        singleton_class.prepend ClassMethods::Prepend
      end

      module ClassMethods

        module Prepend

          private

          def inherited(subclass)
            super
            instance_variables.each do |v|
              subclass.send(:instance_variable_set, v, instance_variable_get(v).clone) if /@_c_/ =~ v
            end
          end

        end

        private

        # Declare a configurable attribute. This is used to declare the configuration methods used in
        # Served::Resource::Base
        def class_configurable(name, options={}, &block)
          instance_eval do
            instance_variable_set(:"@_c_#{name}", options[:default]) if options[:default]
            instance_variable_set(:"@_c_#{name}", block ) if block_given? && !instance_variable_get(:"@#{name}")

            define_singleton_method(name) do |value=nil|
              instance_variable_set(:"@_c_#{name}", value) if value
              value = instance_variable_get(:"@_c_#{name}") unless value
              return value.call if value.is_a? Proc
              value
            end

            define_method(name) do
              self.class.send(name)
            end
          end
        end

      end
    end
  end
end
