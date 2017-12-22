module Served
  module Resource
    module Attributable
      extend ActiveSupport::Concern

      included do
        include Serializable
        singleton_class.prepend ClassMethods::Prepend
      end

      module ClassMethods
        # declare an attribute for the resource
        #
        # @example
        #   class SomeResource
        #     attribute :attr1
        #   end
        #
        # @param name [Symbol] the name of the attribute
        def attribute(name, options = {})
          return if attributes.include?(name)
          attributes[name] = options
          attr_accessor name
        end

        # declare a set of attributes by name
        #
        # @example
        #   class SomeResource
        #     attributes :attr1, :attr2
        #   end
        #
        # @param *attributes [Array] a list of attributes for the resource
        # @return [Hash] declared attributes for the resources
        def attributes(*args)
          args.each { |a| attribute a } unless args.empty?
          @attributes ||= {}
        end

        module Prepend
          def inherited(subclass)
            attributes.each do |name, options|
              subclass.attribute name, options
            end
            super
          end
        end
      end

      def initialize(hash = {})
        reload_with_attributes(normalize_keys(hash))
      end

      # @return [Array] the keys for all the defined attributes
      def attributes
        Hash[self.class.attributes.keys.collect { |name| [name, send(name)] }]
      end

      private

      # Reloads the instance with the new attributes
      # If result is an Errors object it will create validation errors on the instance
      # @return [Boolean]
      def reload_with_attributes(result)
        if result.is_a?(Served::Error)
          serializer.parse_errors(result, self)
          set_attribute_defaults
          false
        else
          attributes = self.class.from_hash(result)
          attributes.each do |name, value|
            set_attribute(name.to_sym, value)
          end
          set_attribute_defaults
          true
        end
      end

      def set_attribute_defaults
        self.class.attributes.each do |attr, options|
          next if options[:default].nil? || send(attr)
          set_attribute(attr, options[:default])
        end
      end

      def set_attribute(name, value)
        instance_variable_set("@#{name}", value)
      end

      def normalize_keys(params)
        case params
        when Hash
          Hash[params.map { |k, v| [k.to_s.tr('-', '_'), normalize_keys(v)] }]
        when Array
          params.map { |v| normalize_keys(v) }
        else
          params
        end
      end
    end
  end
end
