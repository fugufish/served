module Served
  module Resource
    class HttpError < Served::Error
      attr_reader :message
      attr_reader :server_backtrace
      attr_reader :errors
      attr_reader :response
      attr_reader :code

      # Defined in individual error classes
      def self.code
        raise NotImplementedError
      end

      def initialize(resource, response)
        if resource.serializer.respond_to? :exception
          serialized = resource.serializer.exception(response.body).symbolize_keys!

          @error            = serialized[:error]
          @message          = serialized[:exception]
          @server_backtrace = serialized[:backtrace]
          @code             = serialized[:code] || serialized[:code] = self.class.code
          @response         = OpenStruct.new(serialized) # TODO: remove in served 1.0, used for backwards compat

          super("An error '#{code} #{message}' occurred while making this request")
        end
        super "An error occurred '#{self.class.code}'"
      end

      def status
        self.class.status
      end
    end

    # 301 MovedPermanently
    class MovedPermanently < HttpError
      def self.code
        301
      end
    end

    # 400 BadRequest
    class BadRequest < HttpError
      def self.code
        400
      end
    end

    # 401 Unauthorized
    class Unauthorized < HttpError
      def self.code
        401
      end
    end

    # 403 Forbidden
    class Forbidden < HttpError
      def self.code
        403
      end
    end

    # 404 NotFound
    class NotFound < HttpError
      def self.code
        404
      end
    end

    # 405 MethodNotAllowed
    class MethodNotAllowed < HttpError
      def self.code
        405
      end
    end

    # 406 NotAcceptable
    class NotAcceptable < HttpError
      def self.code
        406
      end
    end

    # 408 RequestTimeout
    class RequestTimeout < HttpError
      def self.code
        408
      end
    end

    # 422 UnprocessableEntity
    class UnprocessableEntity < HttpError
      def self.code
        422
      end
    end

    # 500 InternalServerError
    class InternalServerError < HttpError
      def self.code
        500
      end
    end

    # 503 BadGateway
    class BadGateway < HttpError
      def self.code
        503
      end
    end
  end
end
