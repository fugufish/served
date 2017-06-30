require 'addressable/template'
require_relative 'error'

module Served
  # Provides an interface between the HTTP client and the Resource.
  class HTTPClient
    DEFAULT_TEMPLATE = '{/resource*}{/id}.json{?query*}'.freeze

    attr_reader :template, :resource

    delegate :get, :put, :delete, :post, to: :@backend
    delegate :headers, :timeout, :host,  to: :@resource

    class ConnectionFailed < Served::Error
      def initialize(resource)
        super "Resource '#{resource.name}' could not be reached on '#{resource.host}'"
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
