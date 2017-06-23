require_relative 'backends/base'
module Served
  module Backends
    # @private
    def self.[](backend)
      @backends ||= {
        http:     'HTTP',
        patron:   'Patron',
        httparty: 'HTTParty'
      }
      if @backends[backend]
        require_relative "backends/#{backend}"
        return const_get(@backends[backend].classify.to_sym)
      end
      require_relative 'backends/httparty'
      const_get(@backends[:httparty].classify.to_sym)
    end
  end
end
