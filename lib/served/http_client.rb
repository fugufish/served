require 'addressable/template'
module Served
  # Provides an interface between the HTTP client and the Resource.
  class HTTPClient
     include Backends[Served.config.backend]

    HEADERS = { 'Content-type' => 'application/json', 'Accept' => 'application/json' }
    DEFAULT_TEMPLATE = '{/resource*}{/id}.json{?query*}'

    def initialize(host, timeout)
      host += DEFAULT_TEMPLATE unless host =~ /{.+}/
      @template = Addressable::Template.new(host)
      @timeout  = timeout
    end

    private

    def headers
      HEADERS
    end

  end
end
