module Served
  module Resource
    class JsonApiResource < Served::Resource::Base

      # Saves the record to the service. Will call POST if the record does not have an id, otherwise will call PUT
      # to update the record
      #
      # @return [Boolean] returns true or false depending on save success
      def save
        if id
          reload_with_attributes(put)
        else
          reload_with_attributes(post)
        end
      end

      private

      def reload_with_attributes(result)
        if result.is_a?(Served::JsonApiError::Errors)
          result.each do |error|
            if error.source_parameter && self.attributes.keys.include?(error.source_parameter.to_sym)
              self.errors.add(error.source_parameter.to_sym, error_message(error))
            else
              self.errors.add(:base, error_message(error))
            end
          end
          set_attribute_defaults
          false
        else
          result.each do |name, value|
            set_attribute(name.to_sym, value)
          end
          set_attribute_defaults
          true
        end
      end

      def handle_response(response)
        if (200..299).include?(response.code)
          resource_or_array = JSON.parse(response.body)
          resource_or_array.fetch(resource_name.singularize, resource_or_array)
        else
          Served::JsonApiError::Errors.new(response)
        end
      end

      def error_message(error)
        error.detail || error.title || 'Error, but no error message found'
      end
    end
  end
end
