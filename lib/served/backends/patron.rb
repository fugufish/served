require 'patron'
module Served
  module Backends
    # Patron Backend uses {Patron https://github.com/toland/patron} for its client. This backend does not lock the GIL
    # and is thread safe. Use Patron if you need high concurrency.
    class Patron < Base

      def get(endpoint, id, params={})
        serialize_response(::Patron::Session.new(headers: headers, timeout: timeout)
                               .get(template.expand(id: id, query: params, resource: endpoint).to_s))
      rescue ::Patron::ConnectionFailed
        raise Served::HTTPClient::ConnectionFailed.new(resource)
      end

      def put(endpoint, id, body, params={})
        serialize_response(::Patron::Session.new(headers: headers, timeout: timeout)
                               .put(template.expand(id: id, query: params, resource: endpoint).to_s, body))
      rescue ::Patron::ConnectionFailed
        raise Served::HTTPClient::ConnectionFailed.new(resource)
      end

      def post(endpoint, body, params={})
        serialize_response(::Patron::Session.new(headers: headers, timeout: timeout)
                               .post(template.expand(query: params, resource: endpoint).to_s, body))
      rescue ::Patron::ConnectionFailed
        raise Served::HTTPClient::ConnectionFailed.new(resource)
      end

      def delete(endpoint, id, params={})
        serialize_response(::Patron::Session.new(headers: headers, timeout: timeout)
                               .delete(template.expand(id: id, query: params, resource: endpoint).to_s))
      rescue ::Patron::ConnectionFailed
        raise Served::HTTPClient::ConnectionFailed.new(resource)
      end

      def serialize_response(response)
        OpenStruct.new({
                           body: response.body,
                           code: response.status
                       })
      end

    end
  end
end