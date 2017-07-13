module Served
  module Resource
    class InvalidAttributeSerializer < Served::Error
      def initialize(s)
        super "'#{s}' attribute serializer does not exist"
      end
    end
  end
end
