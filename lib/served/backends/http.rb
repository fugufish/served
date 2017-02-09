require 'http'
module Served
  module Backends
    #HTTP Backend uses {https://github.com/httprb/http HTTP} client library.
    class HTTP < Base

      def get(endpoint, id, params={})
        response = ::HTTP
            .timeout(global: timeout)
            .headers(headers)
            .get(template.expand(id: id, query: params, resource: endpoint).to_s)
        serialize_response(response)
      end

      def put(endpoint, id, body, params={})
        response = ::HTTP
            .timeout(global: timeout)
            .headers(headers)
            .put(template.expand(id: id, query: params, resource: endpoint).to_s, body: body)
        serialize_response(response)
      end

      def post(endpoint, body, params={})
        response = ::HTTP
            .timeout(global: timeout)
            .headers(headers)
            .post(template.expand(query: params, resource: endpoint).to_s, body: body)
        serialize_response(response)
      end

      def delete(endpoint, id, params={})
        response = ::HTTP
            .timeout(global: timeout)
            .headers(headers)
            .delete(template.expand(query: params, resource: endpoint, id: id).to_s)
        serialize_response(response)
      end

    end
  end
end