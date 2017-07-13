require 'active_support/configurable'
require 'active_support/core_ext/string'
require 'active_support/core_ext/module'
require 'active_model'

require 'served/error'
require 'served/engine'
require 'served/version'
require 'served/config'
require 'served/backends'
require 'served/http_client'
require 'served/resource'
require 'served/attribute'
require 'served/serializers'

require 'served/serializers/json_api/error'
require 'served/serializers/json_api/errors'

I18n.load_path << File.expand_path("served/locale/en.yml", __dir__)
