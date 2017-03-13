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

      attribute :id

      # Default headers for every request
      HEADERS = {'Content-type' => 'application/json', 'Accept' => 'application/json'}


      # raised when the connection receives a response from a service that does not constitute a 200
      class ServiceError < StandardError
        attr_reader :response

        def initialize(resource, response)
          @response = response
          error = JSON.parse(response.body)
          super "Service #{resource.class.name} responded with an error: #{error['error']} -> #{error['exception']}"
          set_backtrace(error['traces']['Full Trace'].collect {|e| e['trace']})
        end
      end

      class_configurable :resource_name do
        name.split('::').last.tableize
      end

      class_configurable :host do
        Served.config[:hosts][parent.name.underscore.split('/')[-1]] || Served.config[:hosts][:default]
      end

      class_configurable :timeout do
        Served.config.timeout
      end

      class_configurable :_headers do
        HEADERS
      end

      class_configurable :template do
        '{/resource*}{/id}.json{?query*}'
      end

      class << self

        # Defines the default headers that should be used for the request.
        #
        # @param headers [Hash] the headers to send with each requesat
        # @return headers [Hash] the default headers for the class
        def headers(h={})
          headers ||= _headers
          _headers(headers.merge!(h)) unless h.empty?
          _headers
        end

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

      end

      def initialize(options={})
        # placeholder
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
        raise ServiceError.new(self, response) unless (200..299).include?(response.code)
        JSON.parse(response.body)
      end

      def client
        self.class.client
      end

      def presenter
        {resource_name.singularize.to_sym => attributes}
      end

    end
  end
end
