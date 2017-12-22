module Served
  module Resource
    class ResponseInvalid < Served::Error
      def initialize(resource, original_error = false)
        if original_error
          super "The resource '#{resource.name}' failed to serialize the " \
            "response with message: #{original_error.message}'"
          return
        end

        super "The resource '#{resource.name}' returned a response, but the result " \
              "of serialization was `nil`"
      end
    end
  end
end
