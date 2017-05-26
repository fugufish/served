module Served
  module Resource
    class ResponseInvalid < Served::Error

      def initialize(resource, orignal_error=false)
        return super "The resource '#{resource.name}' failed to serialize the response with message: " +
                 "'#{orignal_error.message}'" if orignal_error
        super "The resource '#{resource.name}' returned a response, but the result of serialization was `nil`"
      end

    end
  end
end