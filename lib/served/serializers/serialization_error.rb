module Served
  module Serializers
    class SerializationError < Served::Error

      def initialize(original_exception)
        super("Failed to serialize object with error: '#{original_exception.message}'")
      end

    end
  end
end