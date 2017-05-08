module Served
  module Resource
    module Requestable
      extend ActiveSupport::Concern

      # raised when a handler is defined if the method doesn't exist or if a proc isn't supplied
      class HandlerRequired < StandardError

        def initialize
          super 'a handler is required, it must be a proc or a valid method'
        end

      end

      HEADERS = { 'Content-type' => 'application/json', 'Accept' => 'application/json' }

      included do
        include Configurable

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

        class_configurable :handlers, default: {}

        class_configurable :template do
          '{/resource*}{/id}.json{?query*}'
        end

        handle((200..201), :load)
        handle([204, 202]) { attributes }

        # 400 level errors
        handle(301) { Resource::MovedPermanently }
        handle(400) { Resource::BadRequest }
        handle(401) { Resource::Unauthorized }
        handle(403) { Resource::Forbidden }
        handle(404) { Resource::NotFound }
        handle(405) { Resource::MethodNotAllowed }
        handle(406) { Resource::NotAcceptable }
        handle(408) { Resource::RequestTimeout }
        handle(422) { Resource::UnprocessableEntity }

        # 500 level errors
        handle(500) { Resource::InternalServerError }
        handle(503) { Resource::BadGateway }


      end

      module ClassMethods

        def handle_response(response)
          handler = handlers[response.code]
          if handler.is_a? Proc
            result = handler.call(response.body)
          else
            result = send(handler, response.body)
          end
          if result.ancestors.include? HttpError
            raise result.new(self, response)
          end
          result
        end

        # Sets individual handlers for response codes, accepts a proc or a symbol representing a method
        #
        # @param code [Integer|Range] the response code(s) the handler is to be assigned to
        # @param symbol_or_proc [Symbol|Proc] a symbol representing the method to call, or a proc to be called when
        #   the specific response code has been called. The method or proc should return a hash of attributes, if an
        #   error class is returned it will be raised
        # @yieldreturn [Hash] a hash of attributes, if an error class is returned it will be raised
        def handle(code_or_range, symbol_or_proc=nil, &block)
          raise HandlerRequired unless symbol_or_proc || block_given?
          if code_or_range.is_a?(Range) || code_or_range.is_a?(Array)
            code_or_range.each { |c|
              handlers[c] = symbol_or_proc || block
            }
          else
            handlers[code_or_range] = symbol_or_proc || block
          end
        end

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

      # Saves the record to the service. Will call POST if the record does not have an id, otherwise will call PUT
      # to update the record
      #
      # @return [Boolean] returns true or false depending on save success
      def save
        if id
          reload_with_attributes(put)
        else
          reload_with_attributes(post)
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

      # Destroys the record on the service. Acts on status code
      # If code is a 204 (no content) it will simply return true
      # otherwise it will parse the response and reloads the instance
      #
      # @return [Boolean|self] Returns true or instance
      def destroy(params = {})
        result = delete(params)
        return result if result.is_a?(TrueClass)

        reload_with_attributes(result)
        true
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

      def delete(params={})
        response = client.delete(resource_name, id, params)
        return true if response.code == 204

        handle_response(response)
      end

      def client
        self.class.client
      end


      def handle_response(response)
        self.class.handle_response(response)
      end

    end
  end
end