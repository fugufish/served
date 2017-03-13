module Served
  module Attribute
    class Base
      include Resource::Attributable
      include Resource::Serializable
      include Resource::Validatable

      def initialize(*args)
        # placeholder
      end
    end
  end
end