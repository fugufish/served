require_relative 'attributable'
require_relative 'serializable'
require_relative 'validatable'
require_relative 'configurable'

module Served
  module Resource
    # Service Resources should inherit directly from this class. Provides interfaces necessary for communicating with
    # services based on the namespace. Classes should be namespaced under Services::ServiceName where ServiceName is the
    # name of the service the resource lives on. The resource determines the host of the service based on this
    # this namespace and what is in the configuration.
    #
    # Service Resources supports some ActiveModel validations so that a developer can include client side validations
    # if desired. Validation options can be passed to the #attribute class method using the same options as
    # ActiveModel#validate
    #
    # A resource may also serialize values as specific classes, including nested resources. If serialize is set to a
    # Served Resource, it will validate the nested resource as well as the top level.
    class Base
      include Configurable
      include Attributable
      include Validatable
      include Serializable

      # raised when the connection receives a response from a service that does not constitute a 200
      class ServiceError < StandardError
        attr_reader :response

        def initialize(response)
          @response = response
          super "An error occurred making the request: #{@response.code}"
        end
      end

      class << self

        # Looks up a resource on the service by id. For example `SomeResource.find(5)` would call `/some_resources/5`
        #
        # @param id [Integer] the id of the resource
        # @return [Resource::Base] the resource object.
        def find(id)
          instance = new(id: id)
          instance.reload
        end

        # @return [Served::HTTPClient] the HTTPClient using the configured backend
        def client
          @client ||= Served::HTTPClient.new(self)
        end

        private

        # Everything should allow an id attribute
        def inherited(subclass)
          return if subclass.attributes.include?(:id) # attribute method does this already, but rather not do a
          # class_eval if not necessary
          subclass.class_eval do
            attribute :id
          end
        end

      end

      # Saves the record to the service. Will call POST if the record does not have an id, otherwise will call PUT
      # to update the record
      #
      # @return [Boolean] returns true or false depending on save success
      def save
        if id
          reload_with_attributes(put[resource_name.singularize])
        else
          reload_with_attributes(post[resource_name.singularize])
        end
        true
      end

      # Reloads the resource using attributes from the service
      #
      # @return [self] self
      def reload
        reload_with_attributes(get)
        self
      end

      private

      def get(params={})
        handle_response(client.get(resource_name, id, params))
      end

      def put(params={})
        body = to_json
        handle_response(client.put(resource_name, id, body, params))
      end

      def post(params={})
        body = to_json
        handle_response(client.post(resource_name, body, params))
      end

      def handle_response(response)
        raise ServiceError, response unless (200..299).include?(response.code)
        JSON.parse(response.body)
      end

      def client
        self.class.client
      end

    end
  end
end
