module Served
  module Resource
    class ResponseInvalid < Served::Error

      def initialize(resource, orignal_error)
        super "The resource '#{resource.name}' failed to serialize the response with message: " +
                 "'#{orignal_error.message}'"
      end

    end
  end
end