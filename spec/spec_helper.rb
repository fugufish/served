$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'served'
require 'served/backends/http'
require 'served/backends/httparty'
require 'served/backends/patron'
