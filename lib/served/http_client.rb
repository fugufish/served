require 'addressable/template'
module Served
  # Provides an interface between the HTTP client and the Resource.
  class HTTPClient

    DEFAULT_TEMPLATE = '{/resource*}{/id}.json{?query*}'

    attr_reader :template, :timeout

    delegate :get, :put, :delete, :post, :headers, to: :@backend

    def initialize(host, timeout, headers={})
      host += DEFAULT_TEMPLATE unless host =~ /{.+}/
      @template = Addressable::Template.new(host)
      @timeout  = timeout
      @backend  = Served::Backends[Served.config.backend].new(self)
    end

  end
end
