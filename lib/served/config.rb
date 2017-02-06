module Served
  module Config
    extend ActiveSupport::Concern
    
    included do
      include ActiveSupport::Configurable
      config_accessor :timeout
      config_accessor :backend
      
      configure do |config|
        config.timeout = 30
        config.backend = :http
      end
      
    end
    
  end
end