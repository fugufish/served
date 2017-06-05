module Served

  # TODO: remove in 1.0, this preserves backwards compatibility with 0.2
  module Resource
    class Base
      class ServiceError < StandardError
      end
    end
  end

  class Error < Served::Resource::Base::ServiceError
  end
end