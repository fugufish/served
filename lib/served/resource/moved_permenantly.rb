module Served
  module Resource
    class MovedPermanently < HttpError

      def self.code
        301
      end

    end
  end
end