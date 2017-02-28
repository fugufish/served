module Served
  module Resource
    module Attributable
      extend ActiveSupport::Concern

      included do
        prepend Prepend
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
        def attribute(name, options={})
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
          # filter out validation attributes
           if !@attributes && superclass.respond_to?(:attributes)
            @attributes ||= superclass.send(:attributes)
           elsif !@attributes
             @attributes ||= {}
           end
          @attributes
        end

      end

      module Prepend

        def initialize(options={})
          reload_with_attributes(options.symbolize_keys)
          super
        end

      end

      # @return [Array] the keys for all the defined attributes
      def attributes
        Hash[self.class.attributes.keys.collect { |name| [name, send(name)] }]
      end

      private

      def reload_with_attributes(attributes)
        attributes.each do |name, value|
          set_attribute(name.to_sym, value)
        end
        set_attribute_defaults
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

    end

  end
end