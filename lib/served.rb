require 'httparty'
require 'active_support/configurable'
require 'active_support/core_ext/string'
require 'active_support/core_ext/module'

require 'served/engine'
require 'served/version'
require 'served/http_client'
require 'served/resource'

module Served
  include ActiveSupport::Configurable
  configure do |config|
    config.timeout = 30
  end
end