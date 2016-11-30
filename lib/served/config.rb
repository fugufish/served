module Served
  include ActiveSupport::Configurable

  config_accessor :timeout do
    30
  end

  config_accessor :backend do
    :httparty
  end

end