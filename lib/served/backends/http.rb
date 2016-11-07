require 'http'

module Served
  module Backends

    def get(endpoint, id, params={})
      ::HTTP
        .timeout(global: @timeout)
        .headers(HEADERS)
        .get(@template.expand(id: id, query: params, resource: endpoint).to_s)
    end

    def put(endpoint, id, body, params={})
      ::HTTP
        .timeout(global: @timeout)
        .headers(HEADERS)
        .put(@template.expand(id: id, query: params, resource: endpoint).to_s, body: Oj.dump(body))
    end

    def post(endpoint, body, params={})
      ::HTTP
        .timeout(global: @timeout)
        .headers(HEADERS)
        .post(@template.expand(query: params, resource: endpoint).to_s, body: Oj.dump(body))
    end

    def delete(endpoint, id, params={})
      ::HTTP
        .timeout(global: @timeout)
        .headers(HEADERS)
        .post(@template.expand(query: params, resource: endpoint, id: id).to_s)
    end

  end
end