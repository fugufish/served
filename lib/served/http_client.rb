require 'addressable/template'
module Served
  # Provides an interface between the HTTP client and the Resource.
  class HTTPClient

    DEFAULT_TEMPLATE = '{/resource*}{/id}.json{?query*}'

    attr_reader :template, :resource

    delegate :get, :put, :delete, :post, to: :@backend
    delegate :headers, :timeout, :host,  to: :@resource

    class ConnectionFailed < StandardError

        def initialize(resource)
          super "Resource #{resource.name} could not be reached on #{resource.host}"
        end

      end

    def initialize(resource)
      @resource = resource
      h = host + @resource.template
      @template = Addressable::Template.new(h)
      @backend  = Served::Backends[Served.config.backend].new(self)
    end

  end
end
