require_relative 'serializers/json'
module Served
  include ActiveSupport::Configurable
  config_accessor :timeout
  config_accessor :backend
  config_accessor :serializer

  configure do |config|
    config.timeout    = 30
    config.backend    = :http
    config.hosts      = {}
    config.serializer = Served::Serializers::Json
  end

end