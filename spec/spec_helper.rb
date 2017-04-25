$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'byebug'
require 'served'
require 'served/backends/http'
require 'served/backends/httparty'
require 'served/backends/patron'
