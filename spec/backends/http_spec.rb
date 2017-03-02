require 'spec_helper'
describe Served::Backends::Patron do
  let(:resource) {
    Class.new(Served::Resource::Base) do
    end
  }

  subject { Served::HTTPClient.new(resource) }

  before :all do
    Served.configure do |c|
      c.backend = :http
      c.hosts = {default: 'testhost:3000'}
    end
  end

  it 'should choose the appropriate backend' do
    expect(subject.instance_variable_get(:@backend)).to be_a Served::Backends::HTTP
  end

  describe 'requests' do
    let(:backend)       { subject.instance_variable_get(:@backend) }
    let(:endpoint)      { 'things' }
    let(:id)            { 1 }
    let(:params)        { {foo: :bar} }
    let(:body)          { { attr1: 1 } }
    let(:response)      { double('response', body: body, status: 200)}
    let(:http_instance) { instance_double(::HTTP::Client) }

    context '#get' do

      it 'calls get with the expanded template' do
        expect(::HTTP).to receive(:timeout).with({global: resource.timeout}).and_return(http_instance)
        expect(http_instance).to receive(:headers).with(resource.headers).and_return(http_instance)
        expect(http_instance).to receive(:get).with(subject.template.expand(id: id, query: params, resource: endpoint).to_s)
                               .and_return(response)
        subject.get(endpoint, id, params)
      end

      it 'raises Served::HTTPClient::ConnecitonFailed when a connection failure occurs' do
        expect(::HTTP).to receive(:timeout).with({global: resource.timeout}).and_return(http_instance)
        expect(http_instance).to receive(:headers).with(resource.headers).and_return(http_instance)
        expect(http_instance).to receive(:get).and_raise(::HTTP::ConnectionError)
        expect { subject.get(endpoint, id, params) }.to raise_error(Served::HTTPClient::ConnectionFailed)
      end

    end

    context '#put' do

      it 'calls get with the expanded template' do
        expect(::HTTP).to receive(:timeout).with({global: resource.timeout}).and_return(http_instance)
        expect(http_instance).to receive(:headers).with(resource.headers).and_return(http_instance)
        expect(http_instance).to receive(:put).with(subject.template.expand(id: id, query: params, resource: endpoint).to_s, body: body)
                                     .and_return(response)
        subject.put(endpoint, id, body, params)
      end

      it 'raises Served::HTTPClient::ConnecitonFailed when a connection failure occurs' do
        expect(::HTTP).to receive(:timeout).with({global: resource.timeout}).and_return(http_instance)
        expect(http_instance).to receive(:headers).with(resource.headers).and_return(http_instance)
        expect(http_instance).to receive(:put).and_raise(::HTTP::ConnectionError)
        expect { subject.put(endpoint, id, body, params) }.to raise_error(Served::HTTPClient::ConnectionFailed)
      end

    end


    context '#post' do

      it 'calls get with the expanded template' do
        expect(::HTTP).to receive(:timeout).with({global: resource.timeout}).and_return(http_instance)
        expect(http_instance).to receive(:headers).with(resource.headers).and_return(http_instance)
        expect(http_instance).to receive(:post).with(subject.template.expand(query: params, resource: endpoint).to_s, body: body)
                                     .and_return(response)
        subject.post(endpoint, body, params)
      end

      it 'raises Served::HTTPClient::ConnecitonFailed when a connection failure occurs' do
        expect(::HTTP).to receive(:timeout).with({global: resource.timeout}).and_return(http_instance)
        expect(http_instance).to receive(:headers).with(resource.headers).and_return(http_instance)
        expect(http_instance).to receive(:post).and_raise(::HTTP::ConnectionError)
        expect { subject.post(endpoint, params) }.to raise_error(Served::HTTPClient::ConnectionFailed)
      end

    end

    context '#delete' do

      it 'calls get with the expanded template' do
        expect(::HTTP).to receive(:timeout).with({global: resource.timeout}).and_return(http_instance)
        expect(http_instance).to receive(:headers).with(resource.headers).and_return(http_instance)
        expect(http_instance).to receive(:delete).with(subject.template.expand(id: id, query: params, resource: endpoint).to_s)
                                     .and_return(response)
        subject.delete(endpoint, id, params)
      end

      it 'raises Served::HTTPClient::ConnecitonFailed when a connection failure occurs' do
        expect(::HTTP).to receive(:timeout).with({global: resource.timeout}).and_return(http_instance)
        expect(http_instance).to receive(:headers).with(resource.headers).and_return(http_instance)
        expect(http_instance).to receive(:post).and_raise(::HTTP::ConnectionError)
        expect { subject.delete(endpoint, id, params) }.to raise_error(Served::HTTPClient::ConnectionFailed)
      end

    end

  end

end