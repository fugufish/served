module Served
  module Resource
    class InvalidAttributeSerializer < Served::Error
      def initialize(ser)
        super "'#{ser}' attribute serializer does not exist"
      end
    end
  end
end
