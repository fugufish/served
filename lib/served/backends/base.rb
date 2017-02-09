module Served
  module Backends
    class Base
      delegate :headers, :template, :timeout, to: :@client

      def initialize(client)
        @client = client
      end

      private

      def serialize_respoinse(response)
        response
      end

    end
  end
end