require 'patron'
module Served
  module Backends
    # Patron Backend uses {Patron https://github.com/toland/patron} for its client. This backend does not lock the GIL
    # and is thread safe. Use Patron if you need high concurrency.
    class Patron < Base

      def get(endpoint, id, params={})
        ::Patron::Session.new(headers: headers, timeout: timeout)
            .get(template.expand(id: id, query: params, resource: endpoint).to_s)
      end

      def put(endpoint, id, body, params={})
        ::Patron::Session.new(headers: headers, timeout: timeout)
            .put(template.expand(id: id, query: params, resource: endpoint).to_s, body)
      end

      def post(endpoint, body, params={})
        ::Patron::Session.new(headers: headers, timeout: timeout)
            .post(template.expand(query: params, resource: endpoint).to_s, body)
      end

      def delete(endpoint, id, params={})
        ::Patron::Session.new(headers: headers, timeout: timeout)
            .delete(template.expand(id: id, query: params, resource: endpoint).to_s)
      end

    end
  end
end