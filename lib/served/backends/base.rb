module Served
  module Backends
    class Base
      delegate :headers, :resource, :template, :timeout, to: :@client

      def initialize(client)
        @client = client
      end

      def serialize_response(response)
        response
      end
    end
  end
end
