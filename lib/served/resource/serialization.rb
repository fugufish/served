module Served
  module Resource
    module Serialization
      extend ActiveSupport::Concern

      included do
        singleton_class.prepend PrependClassMethods
        prepend PrependInstanceMethods
      end

      class InvalidPresenter < StandardError
      end

      module PrependClassMethods

        def attribute(name, options={})
          super
          serializer_for_attribute(name, options[:serialize]) if options[:serialize]
        end

      end

      module PrependInstanceMethods

        def set_attribute(name, value)
          value = self.class.attribute_serializers[name].new(value) if self.class.attribute_serializers[name]
          super
        end

        protected

        def run_validations!
          super
          self.class.attribute_serializers.each_key do |attribute|
            attr = send(attribute)
            errors.add(attribute, :invalid) unless attr.valid?
          end
          errors.empty?
        end

      end

      module ClassMethods

        def attribute_serializers
          @attribute_serializers ||= {}
        end

        private

        def serializer_for_attribute(attr, serializer)
          attribute_serializers[attr] = serializer
        end

      end

      # renders the model as json
      def to_json
        raise InvalidPresenter, 'Presenter must respond to #to_json' unless presenter.respond_to? :to_json
        presenter.to_json
      end

      # override this to return a presenter to be used for serialization, otherwise all attributes will be
      # serialized
      def presenter
        {resource_name.singularize => attributes}
      end

    end
  end
end