require 'http'
module Served
  module Backends
    #HTTP Backend uses {https://github.com/httprb/http HTTP} client library.
    class HTTP < Base

      def get(endpoint, id, params={})
        ::HTTP
            .timeout(global: timeout)
            .headers(headers)
            .get(template.expand(id: id, query: params, resource: endpoint).to_s)
      end

      def put(endpoint, id, body, params={})
        ::HTTP
            .timeout(global: timeout)
            .headers(headers)
            .put(template.expand(id: id, query: params, resource: endpoint).to_s, body: body)
      end

      def post(endpoint, body, params={})
        ::HTTP
            .timeout(global: timeout)
            .headers(headers)
            .post(template.expand(query: params, resource: endpoint).to_s, body: body)
      end

      def delete(endpoint, id, params={})
        ::HTTP
            .timeout(global: timeout)
            .headers(headers)
            .delete(template.expand(query: params, resource: endpoint, id: id).to_s)
      end

    end
  end
end