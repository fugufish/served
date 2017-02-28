require 'spec_helper'
describe Served::HTTPClient do

  before :each do
    Served.send(:remove_const, :HTTPClient)
    load File.expand_path('../../lib/served/http_client.rb', __FILE__)
  end


  let(:resource) { Served::Resource::Base.new }

  subject { Served::HTTPClient.new(resource) }

  context 'with an addressable template' do
    subject { Served::HTTPClient.new(resource) }


    it 'does not use the default config template' do
      expect(subject.instance_variable_get(:@template).
          expand(resource: 'bar').to_s).to eq('http://host/bar.foo')
    end

  end

  # also tests the default template

  context Served::Backends::HTTParty do
    before :all do
      Served.configure do |config|
        config.backend = :httparty
      end
    end

    describe '#get' do
      it 'calls the endpoint with the correct query and headers' do
        expect(::HTTParty).to receive(:get)
                                  .with('http://host/dir1/dir2/test/1.json?q=1',
                                        headers: Served::Resource::Configurable::HEADERS,
                                        timeout: Served.config.timeout
                                  ).and_return(true)
        subject.get(%w(dir1 dir2 test), 1, {q: 1})
      end
    end

    describe '#post' do
      it 'calls the endpoint with the correct query and headers' do
        expect(::HTTParty).to receive(:post)
                                  .with('http://host/test.json?q=1',
                                        body: {foo: :bar}.to_json,
                                        headers: Served::Resource::Configurable::HEADERS,
                                        timeout: Served.config.timeout
                                  ).and_return(true)
        subject.post('test', {foo: :bar}.to_json, {q: 1})
      end
    end

    describe '#put' do
      it 'calls the endpoint with the correct query and headers' do
        expect(::HTTParty).to receive(:put).
            with(
                'http://host/test/1.json?q=1',
                body: {foo: :bar}.to_json,
                headers: Served::Resource::Configurable::HEADERS,
                timeout: Served.config.timeout
            ).and_return(true)
        subject.put('test', 1, {foo: :bar}.to_json, {q: 1})
      end
    end

    describe '#delete' do
      it 'calls the endpoint with the correct query and headers' do
        expect(::HTTParty).to receive(:delete).
            with(
                'http://host/test/1.json?q=1',
                headers: Served::Resource::Configurable::HEADERS,
                timeout: Served.config.timeout
            ).and_return(true)
        subject.delete('test', 1, {q: 1})
      end
    end

  end

  context Served::Backends::HTTP do
    let(:http_chain_timeout) { ::HTTP.timeout(global: Served.config.timeout) }
    let(:http_chain_headers) { ::HTTP.headers(Served::Resource::Configurable::HEADERS) }

    before :all do
      Served.configure do |config|
        config.backend = :http
      end

    end


    describe '#get' do

      it 'calls the endpoint with the correct query and headers' do
        expect(::HTTP).to receive(:timeout).with(global: Served.config.timeout).and_return(http_chain_timeout)
        expect(http_chain_timeout).to receive(:headers).and_return(http_chain_headers)
        expect(http_chain_headers).to receive(:get).with('http://host/dir1/dir2/test/1.json?q=1').and_return(true)
        subject.get(%w(dir1 dir2 test), 1, {q: 1})
      end

    end

    describe '#put' do

      it 'calls the endpoint with the correct query and headers' do
        expect(::HTTP).to receive(:timeout).with(global: Served.config.timeout).and_return(http_chain_timeout)
        expect(http_chain_timeout).to receive(:headers).and_return(http_chain_headers)
        expect(http_chain_headers).to receive(:put)
                                          .with('http://host/test/1.json?q=1', body: {foo: :bar}.to_json).and_return(true)
        subject.put('test', 1, {foo: :bar}.to_json, {q: 1})
      end

    end

    describe '#post' do

      it 'calls the endpoint with the correct query and headers' do
        expect(::HTTP).to receive(:timeout).with(global: Served.config.timeout).and_return(http_chain_timeout)
        expect(http_chain_timeout).to receive(:headers).and_return(http_chain_headers)
        expect(http_chain_headers).to receive(:post)
                                          .with('http://host/test.json?q=1', body: {foo: :bar}.to_json).and_return(true)
        subject.post('test', {foo: :bar}.to_json, {q: 1})
      end

    end

    describe '#delete' do

      it 'calls the endpoint with the correct query and headers' do
        expect(::HTTP).to receive(:timeout).with(global: Served.config.timeout).and_return(http_chain_timeout)
        expect(http_chain_timeout).to receive(:headers).and_return(http_chain_headers)
        expect(http_chain_headers).to receive(:delete)
                                          .with('http://host/test/1.json?q=1').and_return(true)
        subject.delete('test', 1, {q: 1})
      end

    end

  end

  context Served::Backends::Patron do

    let(:session) { instance_double(Patron::Session) }

    before :all do
      Served.configure do |config|
        config.backend = :patron
      end

    end

    describe '#get' do

      it 'calls the endpoint with the correct query and headers' do
        expect(::Patron::Session).to receive(:new)
                                       .with(headers: Served::Resource::Configurable::HEADERS, timeout: Served.config.timeout)
        .and_return(session)
        expect(session).to receive(:get).with('http://host/dir1/dir2/test/1.json?q=1')
        subject.get(%w(dir1 dir2 test), 1, {q: 1})
      end

    end

    describe '#post' do

      it 'calls the endpoint with the correct query and headers' do
        expect(::Patron::Session).to receive(:new)
                                         .with(headers: Served::Resource::Configurable::HEADERS, timeout: Served.config.timeout)
                                         .and_return(session)
        expect(session).to receive(:post).with('http://host/test.json?q=1', {foo: :bar}.to_json)
        subject.post('test', {foo: :bar}.to_json, {q: 1})
      end

    end

    describe '#put' do

      it 'calls the endpoint with the correct query and headers' do
        expect(::Patron::Session).to receive(:new)
                                         .with(headers: Served::Resource::Configurable::HEADERS, timeout: Served.config.timeout)
                                         .and_return(session)
        expect(session).to receive(:put).with('http://host/test/1.json?q=1', {foo: :bar}.to_json)
        subject.put('test', 1, {foo: :bar}.to_json, {q: 1})
      end

    end


    describe '#delete' do

      it 'calls the endpoint with the correct query and headers' do
        expect(::Patron::Session).to receive(:new)
                                         .with(headers: Served::Resource::Configurable::HEADERS, timeout: Served.config.timeout)
                                         .and_return(session)
        expect(session).to receive(:delete).with('http://host/test/1.json?q=1')
        subject.delete('test', 1, {q: 1})
      end

    end

  end


end
