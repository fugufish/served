module Served
  module Support
    module Serializable
      extend ActiveSupport::Concern

      # pseudo boolean class for serialization
      class Boolean; end

      # Specialized class serializers
      SERIALIZERS = {
          Fixnum =>  {call: :to_i},
          String =>  {call: :to_s},
          Symbol =>  {call: :to_sym},
          Float =>   {call: :to_f},
          Boolean => { converter: -> (value) {
            return false unless value == "true"
            true
          }}
      }

      included do
        include Attributable
        prepend Prepend
      end

      class InvalidPresenter < StandardError
      end

      module Prepend

        def set_attribute(name, value)
          return unless self.class.attributes[name]
          if serializer = self.class.attributes[name][:serialize]
            if serializer.is_a? Proc
              value = serializer.call(value)
            elsif s = SERIALIZERS[serializer]
              value = value.send(s[:call]) if s[:call] && value.respond_to?(s[:call])
              value = s[:converter].call(value) if s[:converter]
            else
              value = serializer.new(value)
            end
          end
          super
        end
        
      end

      module ClassMethods

        private

        def serializer_for_attribute(attr, serializer)
          attributes[attr][:serializer] = serializer
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