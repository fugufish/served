require 'json'
module Served
  module Serializers

    # The default serializer assumes that the default Rails API response is used for both data and errors.
    module Json

      def serialize_response(data)
        JSON.parse(data)
      rescue => e
        raise SerializationError.new(e)
      end

      def serialize_resource
        if serializeable_options[:root]
          {self.class.name.underscore => attributes.to_json}
        else
          attributes.to_json
        end
      end

      def serialize_error(data)
        JSON.parse(data)
      rescue => e
        raise SerializationError.new(e)
      end

    end
  end
end
