module Served
  module JsonApiError
    class Errors
      include Enumerable
      attr_reader :errors

      def initialize(errors_hash)
        @errors = errors_hash.map { |error| Error.new(error) }
      end

      def each(&block)
        errors.each(&block)
      end
    end
  end
end
