module Served
  module Serializers
    module JsonApi

      def self.load(resource, response)
        data = JSON.parse(response.body)['data']
        data = normalize_keys(data)
        attributes = restructure_json(data)
        merge_relationships(attributes, data) if data['relationships']
        attributes
      end

      def self.dump(resource, attributes)
        attributes.to_json
      end

      def self.exception(resource, response)
        data = JSON.parse(response.body)['data']
        errors = data['errors']
        if errors.length == 1
          return serialize_individual_error(error)
        else
          return {
             error:     'Multiple Errors',
             exception: 'Multiple Errors were received from the resource',
             errors: errors.collect { |e| serialize_individual_error(e) }
          }
        end
      end

      private

      def serialize_individual_error(error)
        {
           error:     error[:title],
           exception: error[:detail],
           backtrace: error[:source],
           code:      error[:code]
        }
      end

      end

      def merge_relationships(restructured, data)
        data['relationships'].keys.each do |relationship|
          rel = data['relationships'][relationship]
          return unless rel && rel['data']

          rel_data = rel['data']

          relationship_attributes = if rel_data.is_a?(Array)
                                      rel_data.inject([]) { |ary, r| ary << restructure_json(r) }
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

      def normalize_keys(params)
        case params
          when Hash
            Hash[params.map { |k, v| [k.to_s.tr('-', '_'), normalize_keys(v)] }]
          when Array
            params.map { |v| normalize_keys(v) }
          else
            params
        end
      end

    end
  end
end