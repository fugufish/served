require_relative 'attributable'
require_relative 'serializable'
require_relative 'validatable'
require_relative 'requestable'
require_relative 'configurable'
require_relative 'resource_invalid'

require_relative 'http_errors'

module Served
  module Resource
    # Service Resources should inherit directly from this class. Provides
    # interfaces necessary for communicating with services based on the namespace.
    # Classes should be namespaced under Services::ServiceName where ServiceName is
    # the name of the service the resource lives on. The resource determines the
    # host of the service based on this this namespace and what is in the
    # configuration.
    #
    # Service Resources supports some ActiveModel validations so that a developer can
    # include client side validations if desired. Validation options can be passed
    # to the #attribute class method using the same options as ActiveModel#validate.
    #
    # A resource may also serialize values as specific classes, including nested
    # resources. If serialize is set to a Served Resource, it will validate the
    # nested resource as well as the top level.
    class Base
      include Configurable
      include Requestable
      include Attributable
      include Validatable
      include Serializable

      attribute :id
    end
  end
end
