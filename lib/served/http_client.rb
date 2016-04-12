require 'addressable/template'
module Served
  # Provides an interface between HTTParty and the models. Most of the crap in here is self explanatory
  class HTTPClient
    HEADERS = { 'Content-type' => 'application/json', 'Accept' => 'application/json' }
    DEFAULT_TEMPLATE = '{/resource*}{/id}.json{?query*}'

    def initialize(host, timeout)
      host += DEFAULT_TEMPLATE unless host =~ /{.+}/
      @template = Addressable::Template.new(host)
      @timeout  = timeout
    end

    def get(endpoint, id, params={})
      HTTParty.get(@template.expand(id: id, query: params, resource: endpoint).to_s,
                   headers: HEADERS,
                   timeout: @timeout
      )
    end

    def put(endpoint, id, body, params={})
      HTTParty.put(@template.expand(id: id, query: params, resource: endpoint).to_s,
        body:    body,
        headers: HEADERS,
        timeout: @timeout
      )
    end

    def post(endpoint, body, params={})
      HTTParty.post(@template.expand(query: params, resource: endpoint).to_s,
        body:    body,
        headers: HEADERS,
        timeout: @timeout
      )
    end
  end
end
