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
      include Support::Attributable
      include Support::Validatable
      include Support::Serializable

      # raised when an attribute is passed to a resource that is not declared
      class InvalidAttributeError < StandardError; end

      # raised when the connection receives a response from a service that does not constitute a 200
      class ServiceError < StandardError
        attr_reader :response

        def initialize(response)
          @response = response
          super "An error occurred making the request: #{@response.code}"
        end
      end

      class << self


        # Defines the default headers that should be used for the request.
        #
        # @param headers [Hash] the headers to send with each requesat
        # @return headers [Hash] the default headers for the class
        def headers(h={})
          @headers ||= {}
          @headers.merge!(h) unless h.empty?
          @headers
        end

        # Looks up a resource on the service by id. For example `SomeResource.find(5)` would call `/some_resources/5`
        #
        # @param id [Integer] the id of the resource
        # @return [Resource::Base] the resource object.
        def find(id)
          instance = new(id: id)
          instance.reload
        end

        # Get or set the resource name for the given resource used for endpoint generation
        #
        # @param resource [String] the name of the resource
        # @return [String] the name of the resource. `SomeResource.resource_name` will return `some_resources`
        def resource_name(resource=nil)
          @resource_name = resource if resource
          @resource_name || name.split('::').last.tableize
        end

        # Get or set the host for the resource
        #
        # @param host [String] the resource host
        # @return [String] or [Hash] the configured host.
        # @see Services::Configuration
        def host(h=nil)
          @host = h if h
          @host ||= Served.config[:hosts][parent.name.underscore.split('/')[-1]]
        end

        # Get or set the timeout for the current resource
        #
        # @return [Integer] allowed timeout in seconds
        def timeout(sec=nil)
          @timeout = sec if sec
          @timeout || Served.config.timeout
        end

        def client
          @connection ||= Served::HTTPClient.new(host_config, timeout, headers)
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

      # @see Services::Resource::Base::resource_name
      def resource_name
        self.class.resource_name
      end

      # Saves the record to the service. Will call POST if the record does not have an id, otherwise will call PUT
      # to update the record
      def save
        if id
          reload_with_attributes(put[resource_name.singularize])
        else
          reload_with_attributes(post[resource_name.singularize])
        end
        true
      end

      alias_method :save!, :save # TODO: differentiate save! and safe much the same AR does.

      def attributes
        Hash[self.class.attributes.keys.collect { |name| [name, send(name)] }]
      end

      # Reloads the resource using attributes from the service
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
