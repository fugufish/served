require 'httparty'
module Served
  module Backends
    # HTTParty Backend uses the {https://github.com/jnunemaker/httparty HTTParty} client
    module HTTParty

      def get(endpoint, id, params={})
        ::HTTParty.get(@template.expand(id: id, query: params, resource: endpoint).to_s,
                       headers: headers,
                       timeout: @timeout
        )
      end

      def put(endpoint, id, body, params={})
        ::HTTParty.put(@template.expand(id: id, query: params, resource: endpoint).to_s,
                       body: body,
                       headers: headers,
                       timeout: @timeout
        )
      end

      def post(endpoint, body, params={})
        ::HTTParty.post(@template.expand(query: params, resource: endpoint).to_s,
                        body: body,
                        headers: headers,
                        timeout: @timeout
        )
      end

      def delete(endpoint, id, params={})
        ::HTTParty.delete(@template.expand(id: id, query: params, resource: endpoint).to_s,
                          headers: headers,
                          timeout: @timeout
        )
      end

    end
  end
end