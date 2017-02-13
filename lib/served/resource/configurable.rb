module Served
  module Resource
    module Configurable
      extend ActiveSupport::Concern

      # Default headers for every request
      HEADERS = { 'Content-type' => 'application/json', 'Accept' => 'application/json' }

      included do
        icattr_accessor :resource_name do
          name.split('::').last.tableize
        end

        icattr_accessor :host do
          Served.config[:hosts][parent.name.underscore.split('/')[-1]]
        end

        icattr_accessor :timeout do
          Served.config.timeout
        end

        icattr_accessor :_headers do
          Resource::Configurable::HEADERS
        end

        icattr_accessor :template do
          '{/resource*}{/id}.json{?query*}'
        end

      end

      module ClassMethods

        # Defines the default headers that should be used for the request.
        #
        # @param headers [Hash] the headers to send with each requesat
        # @return headers [Hash] the default headers for the class
        def headers(h={})
          headers ||= _headers
          _headers(headers.merge!(h)) unless h.empty?
          _headers
        end

        private

        def icattr_accessor(name, &block)
          iattr_set(name, block.call) if block_given?
          instance_eval <<-METHOD
            def #{name}(v=nil)
              iattr_set(:#{name}, v) if v
              iattr_get(:#{name})
            end
          METHOD
        end

        def iattr_get(name)
          _i_accessors[name] || superclass.send(:iattr_get, name) rescue nil
        end

        def iattr_set(name, value)
          _i_accessors[name] = value
        end

        def _i_accessors
          @_i_accessors ||= {}
        end

      end

      # @see Services::Resource::Base::resource_name
      def resource_name
        self.class.resource_name
      end

      # @see Services::Resource::Base::headers
      def headers
        self.class.headers
      end

    end
  end
end
