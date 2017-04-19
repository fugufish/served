module Served
  module JsonApiError
    class Errors
      include Enumerable
      attr_reader :errors

      def initialize(response)
        begin
          errors_hash = JSON.parse(response.body)
          @errors = errors_hash.map { |error| Error.new(error) }
        rescue JSON::ParserError
          @errors = [Error.new(status: response.code, title: 'Parsing Error',
                     detail: 'Service responded with an unparsable body')]
        end
      end

      def each(&block)
        errors.each(&block)
      end
    end
  end
end
