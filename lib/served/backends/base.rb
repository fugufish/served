module Served
  module Backends
    class Base
      delegate :headers, :template, :timeout, to: :@client

      def initialize(client)
        @client = client
      end

    end
  end
end