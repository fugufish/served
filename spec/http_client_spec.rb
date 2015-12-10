require 'spec_helper'
describe Served::HTTPClient do
  subject { Served::HTTPClient.new('http://host') }

  describe '#get' do
    it 'calls the endpoint with the correct query and headers' do
      expect(HTTParty).to receive(:get)
                              .with('http://host/test',
                                    query:   { q: 1 },
                                    headers: Served::HTTPClient::HEADERS,
                                    timeout: Served.config.timeout
                              ).and_return(true)
      subject.get('test', { q: 1 })
    end
  end

  describe '#post' do
    it 'calls the endpoint with the correct query and headers' do
      expect(HTTParty).to receive(:post)
                              .with('http://host/test',
                                    body:    { foo: :bar }.to_json,
                                    query:   { q: 1 },
                                    headers: Served::HTTPClient::HEADERS,
                                    timeout: Served.config.timeout
                              ).and_return(true)
      subject.post('test', { foo: :bar }.to_json, { q: 1 })
    end
  end

  describe '#put' do
    it 'calls the endpoint with the correct query and headers' do
      expect(HTTParty).to receive(:put).
          with(
              'http://host/test',
              body:    { foo: :bar }.to_json,
              query:   { q: 1 },
              headers: Served::HTTPClient::HEADERS,
              timeout: Served.config.timeout
          ).and_return(true)
      subject.put('test', { foo: :bar }.to_json, { q: 1 })
    end
  end
end