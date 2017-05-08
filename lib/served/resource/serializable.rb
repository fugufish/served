require_relative 'response_invalid'

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

        class_configurable :serializer
        class_configurable :use_root_node, default: Served.config.use_root_node

        serializer Served.config.serializer
      end

      module ClassMethods

        def load(string)
          begin
            result = serializer.load(string)
          rescue => e
            raise ResponseInvalid.new(self, e)
          end
          result
        end

        def from_hash(hash)
          hash.each do |name, value|
            hash[name] = serialize_attribute(name, value)
          end
          hash.symbolize_keys
        end

        private

        def serialize_attribute(attr, value)
          return value unless attributes[attr.to_sym] && attributes[attr.to_sym][:serialize]
          s = attributes[attr.to_sym][:serialize]
          return s.call(value) if s.is_a? Proc # already callable
          s = SERIALIZERS[s]
          raise InvalidSerializer.new(s) unless s # no mapping
          if s[:call] && value.respond_to?(s[:call])
            return value.send(s[:call])
          end
          if s[:converter]
            return s[:converter].call(value)
          end
          s.new(value)
        end

      end

      def dump
        self.class.serializer.dump(attributes)
      end

      def load(string)
        self.class.serializer.load(string)
      end


    end
  end
end