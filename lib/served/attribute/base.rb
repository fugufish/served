module Served
  module Attribute
    class Base
      include Resource::Attributable
      include Resource::Serializable
      include Resource::Validatable
    end
  end
end
