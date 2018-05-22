module Served
  module Resource
    class InvalidAttributeSerializer < Served::Error
      def initialize(type)
        super "'#{type}' attribute serializer does not exist"
      end
    end
  end
end
