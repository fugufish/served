module Served
  module Helpers
    module HashHelper
      def normalize_keys(params)
        case params
        when Hash
          Hash[params.map { |k, v| [k.to_s.tr('-', '_'), normalize_keys(v)] }]
        when Array
          params.map { |v| normalize_keys(v) }
        else
          params
        end
      end
    end
  end
end
