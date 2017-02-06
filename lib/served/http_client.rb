require 'addressable/template'
module Served
  # Provides an interface between the HTTP client and the Resource.
  class HTTPClient

    DEFAULT_TEMPLATE = '{/resource*}{/id}.json{?query*}'

    attr_reader :template, :timeout

    delegate :get, :put, :delete, :post, to: :@backend
    delegate :headers,                   to: :@resource

    def initialize(resource, host, timeout)
      host += DEFAULT_TEMPLATE unless host =~ /{.+}/
      @resource = resource
      @template = Addressable::Template.new(host)
      @timeout  = timeout
      @backend  = Served::Backends[Served.config.backend].new(self)
    end

  end
end
