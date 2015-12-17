module Served
  module Resource
    # Service Resources should inherit directly from this class. Provides interfaces necessary for communicating with
    # services based on the namespace. Classes should be namespaced under Services::ServiceName where ServiceName is the
    # name of the service the resource lives on. The resource determines the host of the service based on this
    # this namespace and what is in the configuration.
    class Base
      # raised when an attribute is passed to a resource that is not declared
      class InvalidAttributeError < StandardError; end

      # raised when the connection receives a response from a service that does not constitute a 200
      class ServiceError < StandardError
        def initialize(response)
          @code = response.code
          super "An error occurred making the request: #{@code}"
        end
      end

      class << self
        # declare an attribute for the resource
        #
        # @example
        #   class SomeResource
        #     attribute :attr1
        #   end
        def attribute(name, options={})
          return if attributes.include?(name)
          attributes[name] = options
          attr_accessor name
        end

        # @return [Hash] declared attributes for the resources
        def attributes
          @attributes ||= {}
        end

        # Looks up a resource on the service by id. For example `SomeResource.find(5)` would call `/some_resources/5`
        def find(id)
          instance = new(id: id)
          instance.reload
        end

        # @return [String] the name of the resource. `SomeResource.resource_name` will return `some_resources`
        def resource_name
          name.split('::').last.tableize
        end

        # @return [String] or [Hash] the configured host.
        # @see Services::Configuration
        def host_config
          Served.config[:hosts][parent.name.underscore.split('/')[-1]]
        end

        # @return [Served::HTTPClient] The connection instance to the service host. Note this is not an active
        # connection but a passive one.
        def client
          @connection ||= Served::HTTPClient.new(host_config)
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

      # Instantiates a resource with the given attributes.
      #
      # @raise [InvalidAttributeError] in the case that an attribute is passed that is not declared
      def initialize(attributes={})
        reload_with_attributes(attributes)
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

      # renders the model as json
      def to_json
        raise InvalidPresenter, 'Presenter must respond to #to_json' unless presenter.respond_to? :to_json
        presenter.to_json
      end

      # override this to return a presenter to be used for serialization, otherwise all attributes will be
      # serialized
      def presenter
        { resource_name.singularize => attributes }
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


      def reload_with_attributes(attributes)
        attributes.each do |name, value|
          set_attribute(name.to_sym, value)
        end
        set_attribute_defaults
      end

      def set_attribute_defaults
        self.class.attributes.each do |attr, options|
          next if options[:default].nil? || send(attr)
          set_attribute(attr, options[:default])
        end
      end

      def set_attribute(name, value)
        raise InvalidAttributeError, "`#{name}' is not a valid attribute" unless self.class.attributes.include?(name)
        instance_variable_set("@#{name}", value)
      end

      def client
        self.class.client
      end
    end
  end
end