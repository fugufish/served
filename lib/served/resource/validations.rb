module Served
  module Resource
    # Resource validation functionality
    module Validations
      extend ActiveSupport::Concern

      # Supported Validation Types
      SUPPORTED_VALIDATIONS = [:presence, :numericality, :format]

      included do
        include ActiveModel::Validations
        singleton_class.prepend PrependClassMethods
        prepend PrependInstanceMethods
      end

      module PrependClassMethods

        def attribute(name, options={})
          super
          set_validations_for_attribute(name, options)
        end

      end

      module PrependInstanceMethods

        def save
          return false unless valid?
          super
        end

      end

      module ClassMethods

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