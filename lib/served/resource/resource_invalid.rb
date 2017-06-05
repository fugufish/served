module Served
  module Resource
    class ResourceInvalid < ::Served::Error
      def initialize(resource)
        super "[#{resource.errors.full_messages.join(', ')}]"
      end
    end
  end
end
