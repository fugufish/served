module Served
  # Provides an interface between HTTParty and the models. Most of the crap in here is self explanatory
  class HTTPClient
    HEADERS = { 'Content-type' => 'application/json', 'Accept' => 'application/json' }

    def initialize(host)
      @host = host
    end

    def get(endpoint, params={})
      HTTParty.get("#{@host}/#{endpoint}",
                   query: params,
                   headers: HEADERS,
                   timeout: Served.config.timeout
      )
    end

    def put(endpoint, body, params={})
      HTTParty.put(
        "#{@host}/#{endpoint}",
        body:    body,
        query:   params,
        headers: HEADERS,
        timeout: Served.config.timeout
      )
    end

    def post(endpoint, body, params={})
      HTTParty.post(
        "#{@host}/#{endpoint}",
        body:    body,
        query:   params,
        headers: HEADERS,
        timeout: Served.config.timeout
      )
    end
  end
end