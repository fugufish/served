require_relative 'backends/http'
require_relative 'backends/patron'

module Served
  module Backends

    def self.[](backend)
      @backends ||= {
        http:   HTTP,
        patron: Patron
      }
      @backends[backend]
    end

  end
end