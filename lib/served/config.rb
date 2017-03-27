module Served
  include ActiveSupport::Configurable
  config_accessor :timeout
  config_accessor :backend

  configure do |config|
    config.timeout = 30
    config.backend = :http
    config.hosts   = {}
  end

end