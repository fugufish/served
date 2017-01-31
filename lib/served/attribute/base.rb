module Served
  module Attribute
    class Base
      include Support::Attributable
      include Support::Serializable
      include Support::Validatable
    end
  end
end