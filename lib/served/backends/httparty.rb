require 'httparty'

module Served
  module Backends
    # HTTParty Backend uses the
    # {https://github.com/jnunemaker/httparty HTTParty} client
    class HTTParty < Base
      def get(endpoint, id, params = {})
        ::HTTParty.get(template.expand(id: id,
                                       query: params,
                                       resource: endpoint).to_s,
                       headers: headers,
                       timeout: timeout)
      rescue Errno::ECONNREFUSED
        raise Served::HTTPClient::ConnectionFailed.new(resource)
      end

      def put(endpoint, id, body, params = {})
        ::HTTParty.put(template.expand(id: id,
                                       query: params,
                                       resource: endpoint).to_s,
                       body: body,
                       headers: headers,
                       timeout: timeout)
      rescue Errno::ECONNREFUSED
        raise Served::HTTPClient::ConnectionFailed.new(resource)
      end

      def post(endpoint, body, params = {})
        ::HTTParty.post(template.expand(query: params, resource: endpoint).to_s,
                        body: body,
                        headers: headers,
                        timeout: timeout)
      rescue Errno::ECONNREFUSED
        raise Served::HTTPClient::ConnectionFailed.new(resource)
      end

      def delete(endpoint, id, params = {})
        ::HTTParty.delete(template.expand(id: id,
                                          query: params,
                                          resource: endpoint).to_s,
                          headers: headers,
                          timeout: timeout)
      rescue Errno::ECONNREFUSED
        raise Served::HTTPClient::ConnectionFailed.new(resource)
      end
    end
  end
end
