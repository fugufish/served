module Served
  # Provides an interface between HTTParty and the models. Most of the crap in here is self explanatory
  class HTTPClient
    def initialize(host)
      @host = host
    end

    def get(endpoint, params={})
      HTTParty.get("#{@host}/#{endpoint}", query: params, headers: { 'Content-Type' => 'application/json' })
    end

    def put(endpoint, body={}, params={})
      HTTParty.put(
        "#{@host}/#{endpoint}",
        body:    body.to_json,
        query:   params,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    def post(endpoint, body={}, params={})
      HTTParty.post(
        "#{@host}/#{endpoint}",
        body:    body.to_json,
        query:   params,
        headers: { 'Content-Type' => 'application/json' }
      )
    end
  end
end