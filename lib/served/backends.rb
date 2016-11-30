require_relative 'backends/http'
require_relative 'backends/patron'

module Served
  module Backends

    # @private
    def self.[](backend)
      @backends ||= {
        http:   HTTP,
        patron: Patron
      }
      return @backends[backend] if @backends[backend]
      @backends[:http]
    end

  end
end