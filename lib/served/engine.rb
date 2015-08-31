if Object.const_defined?(:Rails)
  module Served
    class Engine < ::Rails::Engine
    end
  end
end
