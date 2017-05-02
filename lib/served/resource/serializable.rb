module Served
  module Resource
    module Serializable
      extend ActiveSupport::Concern

      # pseudo boolean class for serialization
      unless Object.const_defined?(:Boolean)
        class ::Boolean;
        end
      end

      # Specialized class serializers
      SERIALIZERS = {
         Fixnum  => { call: :to_i },
         String  => { call: :to_s },
         Symbol  => { call: :to_sym, converter: -> (value) {
           if value.is_a? Array
             value = value.map { |a| a.to_sym }
             return value
           end
         } },
         Float   => { call: :to_f },
         Boolean => { converter: -> (value) {
           return false unless value == "true"
           true
         } }
      }

      included do
        include Configurable
        include Attributable
        prepend Prepend

        class_configurable :_serializer
        class_configurable :use_root_node, default: Served.config.use_root_node

        serializer Served.config.serializer
      end

      module Prepend

        # extend set attribute to serialize the value using the :serialize option in the attribute options
        def set_attribute(name, value)
          return unless self.class.attributes[name]
          if serializer = self.class.attributes[name][:serialize]
            if serializer.is_a? Proc
              value = serializer.call(value)
            elsif s = SERIALIZERS[serializer]
              called = false
              if s[:call] && value.respond_to?(s[:call])
                value  = value.send(s[:call])
                called = true
              end
              value = s[:converter].call(value) if s[:converter] && !called
            else
              value = serializer.new(value)
            end
          end
          super
        end

      end

      module ClassMethods



        # Define a new serializer for the class
        #
        # @param mod [Module] the serializer module to use for this class
        def serializer(mod)
          _serializer mod
          instance_exec do
            extend _serializer
          end
        end

        private

        def serializer_for_attribute(attr, serializer)
          attributes[attr][:serializer] = serializer
        end

      end

    end
  end
end