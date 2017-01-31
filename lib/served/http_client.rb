require 'addressable/template'
module Served
  # Provides an interface between the HTTP client and the Resource.
  class HTTPClient

    HEADERS = { 'Content-type' => 'application/json', 'Accept' => 'application/json' }
    DEFAULT_TEMPLATE = '{/resource*}{/id}.json{?query*}'

    attr_reader :template, :timeout

    delegate :get, :put, :delete, :headers, :post, to: :@backend

    def initialize(host, timeout)
      host += DEFAULT_TEMPLATE unless host =~ /{.+}/
      @template = Addressable::Template.new(host)
      @timeout  = timeout
      @backend  = Served::Backends[Served.config.backend].new(self)
    end

    def headers
      HEADERS
    end

  end
end
