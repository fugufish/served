# frozen_string_literal: true

module Served
  module Serializers
    module JsonApi
      # Wraps all error objects
      class Errors < Served::Error
        include Enumerable
        attr_reader :errors

        def initialize(response)
          errors_hash = JSON.parse(response.body)
          @errors = errors_hash['errors'].map { |error| Error.new(error) }
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
end
