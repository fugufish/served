require 'json'
module Served
  module Serializers

    # The default serializer assumes that the default Rails API response is used for both data and errors.
    module Json

      def self.load(data)
        JSON.parse(data)
      end

      def self.dump(attributes)
        attributes.to_json
      end

      def self.exception(data)
        JSON.parse(data)
      end

    end
  end
end
