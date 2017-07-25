require 'json'
module Served
  module Serializers
    # The default serializer assumes that the default Rails API response
    # is used for both data and errors.
    module Json
      def self.load(resource, data)
        parsed = JSON.parse(data)
        # assume we need to return the entire response if it isn't
        # namespaced by keys. TODO: remove after 1.0, this is strictly
        # for backwards compatibility
        resource_name = resource.resource_name
        if resource_name.is_a? Array
          warn '[DEPRECATION] passing an array for resource name will no longer ' \
               'be supported in Served 1.0, please ensure a single string is ' \
               'returned instead'
          resource_name = resource_name.last # backwards compatibility
        end
        parsed[resource_name.singularize] || parsed
      end

      def self.dump(resource, attributes)
        a = Hash[attributes.collect { |k, v| v.blank? ? nil : [k, v] }.compact]
        { resource.resource_name.singularize => a }.to_json
      end

      def self.exception(data)
        JSON.parse(data)
      rescue
        {}
      end
    end
  end
end
