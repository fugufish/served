require 'json'
module Served
  module Serializers

    # The default serializer assumes that the default Rails API response is used for both data and errors.
    module Json

      def self.load(resource, data)
        JSON.parse(data)[resource.resource_name.singularize]
      end

      def self.dump(resource, attributes)
        {resource.resource_name.singularize => attributes.to_json}
      end

      def self.exception(data)
        JSON.parse(data)
      end

    end
  end
end
