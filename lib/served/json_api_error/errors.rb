# frozen_string_literal: true

module Served
  module JsonApiError
    # Wraps all error objects
    class Errors
      include Enumerable
      attr_reader :errors

      def initialize(response)
        errors_hash = JSON.parse(response.body)
        @errors = errors_hash.map { |error| Error.new(error) }
      rescue JSON::ParserError
        @errors = [Error.new(status: response.code, title: 'Parsing Error',
                             detail: 'Service responded with an unparsable body')]
      end

      def each(&block)
        errors.each(&block)
      end
    end
  end
end
