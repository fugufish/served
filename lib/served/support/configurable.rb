module Served
  module Support
    module Configurable
      extend ActiveSupport::Concern

      HEADERS = { 'Content-type' => 'application/json', 'Accept' => 'application/json' }

      module ClassMethods
        
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
        
        # Defines the default headers that should be used for the request.
        #
        # @param headers [Hash] the headers to send with each requesat
        # @return headers [Hash] the default headers for the class
        def headers(h={})
          @headers ||= Support::Configurable::HEADERS
          @headers.merge!(h) unless h.empty?
          @headers
        end
        
      end
    end
  end
end
