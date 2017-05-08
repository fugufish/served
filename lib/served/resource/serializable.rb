require_relative 'response_invalid'
require_relative 'invalid_attribute_serializer'

module Served
  module Resource
    module Serializable
      extend ActiveSupport::Concern

      # pseudo boolean class for serialization
      unless Object.const_defined?(:Boolean)
        class ::Boolean;
        end
      end

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

        def attribute_serializer_for(type)
          case
            when type.class <= NilClass then
              ->(v) { return v }
            when type <= Fixnum, type <= Integer then
              ->(v) { return v.to_i }
            when type <= String then
              ->(v) { return v.to_s }
            when type <= Symbol then
              ->(v) { return v.to_sym }
            when type <= Float then
              ->(v) { return v.to_f }
            when type <= Served::Resource::Base, type <= Served::Attribute::Base then
              -> (v) { type.new(v) }
            when type <= Boolean then
              ->(v) {
                return false unless v == "true"
                true
              }
            else
              raise InvalidAttributeSerializer.new(type)
          end
        end

        def serialize_attribute(attr, value)
          return false unless attributes[attr.to_sym]
          serializer = attribute_serializer_for(attributes[attr.to_sym][:serialize])
          serializer.call(value)
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