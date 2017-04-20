# frozen_string_literal: true

module Served
  module Resource
    class JsonApiResource < Served::Resource::Base
      include Served::Helpers::HashHelper

      class << self
        def all(params = {})
          response = client.get(resource_name, nil, params)
          JSON.parse(response.body)['data'].map do |resource_json|
            attributes = resource_json['attributes'].merge(id: resource_json['id'])
            new(attributes)
          end
        end
      end

      def initialize(attributes = {})
        super normalize_keys(attributes)
      end

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
            if error.source_parameter && attributes.keys.include?(error.source_parameter.to_sym)
              errors.add(error.source_parameter.to_sym, error_message(error))
            else
              errors.add(:base, error_message(error))
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
        if (200..299).cover?(response.code)
          data = JSON.parse(response.body)['data']
          data = normalize_keys(data)
          data['attributes'].merge(id: data['id'])
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
