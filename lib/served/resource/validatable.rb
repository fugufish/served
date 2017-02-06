module Served
  module Resource
    # Resource validation functionality
    module Validatable
      extend ActiveSupport::Concern

      # Supported Validation Types
      SUPPORTED_VALIDATIONS = [
          :presence,
          :numericality,
          :format,
          :inclusion,
          :confirmation
      ]

      class ResourceInvalid < StandardError; end

      included do
        include ActiveModel::Validations
        singleton_class.prepend ClassMethods::Prepend
        prepend Prepend
      end

      module Prepend

        def save
          return false unless valid?
          super
        end



        protected

        def run_validations!
          super
          self.class.attributes.each_key do |attribute|
            attr = send(attribute)
            errors.add(attribute, :invalid) if attr.respond_to?(:valid?) && !attr.valid?
          end
          errors.empty?
        end

      end

      module ClassMethods

        # Saves a resource and raises an error if the save fails.
        def self.save!
          raise ResourceInvalid unless save
          true
        end

        module Prepend

          def attribute(name, options={})
            super
            set_validations_for_attribute(name, options)
          end

        end

        private

        # Sets up any validations for the attribute
        def set_validations_for_attribute(name, options)
          SUPPORTED_VALIDATIONS.each do |validation|
            validates name, validation => options[validation] if options[validation]
          end
        end

      end

    end
  end
end