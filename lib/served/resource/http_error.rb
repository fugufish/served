module Served
  module Resource
    class HttpError < Served::Error
      attr_reader :message
      attr_reader :exception
      attr_reader :server_backtrace
      attr_reader :errors

      # Defined in individual error classes
      def self.code
        raise NotImplementedError
      end

      def initialize(resource, response)
        if resource.respond_to? :serialize_error
          serialized = serialize_error(response)

          @error            = serialized[:error]
          @exception        = serialized[:exception]
          @server_backtrace = serialized[:backtrace]
          @code             = serialized[:code]

          super("An error '#{code || status} #{message}' occurred while making this request")
        end
      end

      def status
        self.class.status
      end

    end
  end
end