require 'json'
module Served
  module Serializers

    # The default serializer assumes that the default Rails API response is used for both data and errors.
    module Json

      def self.load(resource, response)
        data = response.body
        JSON.parse(data)[resource.resource_name.singularize]
      end

      def self.dump(resource, attributes)
        a = Hash[attributes.collect { |k,v| v.blank? ? nil : [k,v] }.compact]
        {resource.resource_name.singularize => a}.to_json
      end

      def self.exception(data)
        JSON.parse(data)
      end

    end
  end
end
