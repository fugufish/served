module Served
  module Resource
    class HttpError < Served::Error
      attr_reader :message
      attr_reader :server_backtrace
      attr_reader :errors
      attr_reader :response
      attr_reader :code

      def initialize(code, resource, response)
        @code = code

        if resource.serializer.respond_to? :exception
          serialized = resource.serializer.exception(response.body).symbolize_keys!

          @error            = serialized[:error]
          @message          = serialized[:exception]
          @server_backtrace = serialized[:backtrace]
          @response         = OpenStruct.new(serialized) # TODO: remove in served 1.0, used for backwards compat

          super("An error '#{code} #{message}' occurred while making this request")
        else
          super "An error occurred '#{code}'"
        end
      end

      def status
        self.class.status
      end
    end

    # 302, 303, 307
    class Redirection < HttpError
    end

    # 301 Moved Permanently
    class MovedPermanently < Redirection
    end

    # 401-499
    class ClientError < HttpError
    end

    # 400 Bad Request
    class BadRequest < ClientError
    end

    # 401 Unauthorized
    class Unauthorized < ClientError
    end

    # 403 Forbidden
    class Forbidden < ClientError
    end

    # 404 Not Found
    class NotFound < ClientError
    end

    # 405 Method Not Allowed
    class MethodNotAllowed < ClientError
    end

    # 406 Not Acceptable
    class NotAcceptable < ClientError
    end

    # 408 Request Timeout
    class RequestTimeout < ClientError
    end

    # 422 Unprocessable Entity
    class UnprocessableEntity < ClientError
    end

    # 5xx Server Error
    class ServerError < HttpError
    end

    # 500 Internal Server Error
    class InternalServerError < ServerError
    end

    # 503 Bad Gateway
    class BadGateway < ServerError
    end
  end
end
