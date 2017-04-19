module Served
  module Resource
    class JsonApiResource < Served::Resource::Base

      # Saves the record to the service. Will call POST if the record does not have an id, otherwise will call PUT
      # to update the record
      #
      # @return [Boolean] returns true or false depending on save success
      def save
        if id
          reload_with_attributes(put[resource_name.singularize])
        else
          reload_with_attributes(post)
        end
        true
      end

      private

      def reload_with_attributes(result)
        if result.is_a?(Served::JsonApiError::Errors)
          result.each do |error|
            attribute = error.source_parameter.to_sym
            if self.attributes.keys.include?(attribute)
              self.errors.add(attribute, error.detail)
            else
              self.errors.add(:base, error.detail)
            end
          end
        else
          result.each do |name, value|
            set_attribute(name.to_sym, value)
          end
          set_attribute_defaults
        end
      end

      def handle_response(response)
        if (200..299).include?(response.code)
          JSON.parse(response.body)
        else
          Served::JsonApiError::Errors.new(response)
        end
      end
    end
  end
end
