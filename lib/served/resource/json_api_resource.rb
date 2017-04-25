# frozen_string_literal: true

module Served
  module Resource
    # Resources that implement JSONApi Spec should use this class
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

      # Destroys the record on the service. Acts on status code
      # If code is a 204 (no content) it will simply return true
      # otherwise it will parse the response and reloads the instance
      #
      # @return [Boolean]
      def destroy(params = {})
        result = delete(params)
        return result if result.is_a?(TrueClass)

        reload_with_attributes(result)
      end

      private

      # Reloads the instance with the new attributes
      # If result is an Errors object it will create validation errors on the instance
      # @return [Boolean]
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

          attributes = restructure_json(data)
          merge_relationships(attributes, data) if data['relationships']
          attributes
        else
          Served::JsonApiError::Errors.new(response)
        end
      end

      # fetches the error message from either detail or title
      # if both are nil a custom message is returned
      def error_message(error)
        error.detail || error.title || 'Error, but no error message found'
      end

      # Parse nested relationship data from JSON api hash structure into a simple nested hash
      #
      #
      # data: {
      #   id: 1,
      #   type: 'customer',
      #   attributes: {
      #     'first-name' => 'foobar'
      #   },
      #   relationships: {
      #     addresses: {
      #       data: [
      #         {
      #           id: 1,
      #           type: 'addresses',
      #           attributes: {
      #             street: 'Broadway',
      #             city: 'New York'
      #           }
      #         }
      #
      def merge_relationships(restructured, data)
        data['relationships'].keys.each do |relationship|
          rel = data['relationships'][relationship]
          return unless rel && rel['data']

          rel_data = rel['data']

          relationship_attributes = if rel_data.is_a?(Array)
                                      rel_data.inject([]) { |ary, rel| ary << restructure_json(rel) }
                                    else
                                      restructure_json(rel_data)
                                    end

          restructured.merge!(relationship => relationship_attributes)
        end
        restructured
      end

      # Restructure JSON API structure into parseable hash
      def restructure_json(data)
        data['attributes'].merge('id' => data['id'])
      end
    end
  end
end
