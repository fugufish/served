require 'httparty'
require 'active_support/configurable'
require 'active_support/core_ext/string'
require 'active_support/core_ext/module'
require 'active_model'

require 'served/engine'
require 'served/version'
require 'served/http_client'
require 'served/support'
require 'served/resource'
require 'served/attribute'

module Served
  include ActiveSupport::Configurable
  configure do |config|
    config.timeout = 30
  end
end