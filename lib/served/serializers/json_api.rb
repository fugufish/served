# frozen_string_literal: true

module Served
  module Serializers
    # JSON API serializing
    module JsonApi
      def self.load(_resource, response)
        if (200..299).cover?(response.code)
          data = JSON.parse(response.body)['data']
          included = JSON.parse(response.body)['included']
          if data.is_a?(Array)
            data.map { |d| normalize_and_restructure(d, included) }
          else
            normalize_and_restructure(data, included)
          end
        else
          Served::Serializers::JsonApi::Errors.new(response)
        end
      end

      def self.parse_errors(result, resource)
        result.each do |error|
          if error.source_parameter && resource.attributes.keys.include?(error.source_parameter.to_sym)
            resource.errors.add(error.source_parameter.to_sym, error_message(error))
          else
            resource.errors.add(:base, error_message(error))
          end
        end
        resource
      end

      # Fetches the error message from either detail or title
      # if both are nil a custom message is returned
      def self.error_message(error)
        error.detail || error.title || 'Error, but no error message found'
      end

      def self.normalize_and_restructure(data, included)
        data = normalize_keys(data)
        attributes = restructure_json(data)
        merge_relationships(attributes, data, included) if data['relationships']
        attributes
      end

      def self.dump(_resource, attributes)
        attributes.to_json
      end

      def self.normalize_keys(params)
        case params
        when Hash
          Hash[params.map { |k, v| [k.to_s.tr('-', '_'), normalize_keys(v)] }]
        when Array
          params.map { |v| normalize_keys(v) }
        else
          params
        end
      end

      def self.serialize_individual_error(error)
        {
          json_api: error[:title],
          exception: error[:detail],
          backtrace: error[:source],
          code: error[:code]
        }
      end

      def self.merge_relationships(restructured, data, included)
        data['relationships'].keys.each do |relationship|
          rel = data['relationships'][relationship]
          next unless rel && rel['data']
          rel_data = rel['data']

          relationship_attributes = if rel_data.is_a?(Array)
                                      rel_data.inject([]) { |ary, r| ary << restructure_relationship(r, included) }
                                    else
                                      restructure_relationship(rel_data, included)
                                    end
          restructured.merge!(relationship => relationship_attributes)
        end
        restructured
      end

      # Restructure JSON API structure into parseable hash
      def self.restructure_json(data)
        data['attributes'].merge('id' => data['id'])
      end

      def self.restructure_relationship(resource, included)
        relationship = included.find {|r| resource['id'] == r['id'] && resource['type'] == r['type']}
        relationship['attributes'].merge('id' => resource['id']) if relationship
      end
    end
  end
end
