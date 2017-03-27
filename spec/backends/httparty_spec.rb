require 'spec_helper'
describe Served::Backends::HTTP do
  let(:resource) {
    Class.new(Served::Resource::Base) do
    end
  }

  subject { Served::HTTPClient.new(resource) }

  before :all do
    Served.configure do |c|
      c.backend = :httparty
      c.hosts = {default: 'http://testhost:3000'}
    end
  end

  it 'should choose the appropriate backend' do
    expect(subject.instance_variable_get(:@backend)).to be_a Served::Backends::HTTParty
  end

  describe 'requests' do
    let(:backend)       { subject.instance_variable_get(:@backend) }
    let(:endpoint)      { 'things' }
    let(:id)            { 1 }
    let(:params)        { {foo: :bar} }
    let(:body)          { { attr1: 1 } }
    let(:response)      { double('response', body: body, status: 200)}

    context '#get' do

      it 'calls get with the expanded template' do
        expect(::HTTParty).to receive(:get)
                                  .with(subject.template.expand(id: id, query: params, resource: endpoint).to_s,
                                  headers: resource.headers,
                                  timeout: resource.timeout)
                               .and_return(response)
        subject.get(endpoint, id, params)
      end

      it 'raises Served::HTTPClient::ConnecitonFailed when a connection failure occurs' do
        expect(::HTTParty).to receive(:get).and_raise(Errno::ECONNREFUSED)
        expect { subject.get(endpoint, id, params) }.to raise_error(Served::HTTPClient::ConnectionFailed)
      end

    end

    context '#put' do

      it 'calls get with the expanded template' do
        expect(::HTTParty).to receive(:put)
                                  .with(subject.template.expand(id: id, query: params, resource: endpoint).to_s,
                                        body: body,
                                        headers: resource.headers,
                                        timeout: resource.timeout)
                                  .and_return(response)
        subject.put(endpoint, id, body, params)
      end

      it 'raises Served::HTTPClient::ConnecitonFailed when a connection failure occurs' do
        expect(::HTTParty).to receive(:put).and_raise(Errno::ECONNREFUSED)
        expect { subject.put(endpoint, id, body, params) }.to raise_error(Served::HTTPClient::ConnectionFailed)
      end

    end


    context '#post' do

      it 'calls get with the expanded template' do
        expect(::HTTParty).to receive(:post)
                                  .with(subject.template.expand(query: params, resource: endpoint).to_s,
                                        body: body,
                                        headers: resource.headers,
                                        timeout: resource.timeout)
                                  .and_return(response)
        subject.post(endpoint, body, params)
      end

      it 'raises Served::HTTPClient::ConnecitonFailed when a connection failure occurs' do
        expect(::HTTParty).to receive(:post).and_raise(Errno::ECONNREFUSED)
        expect { subject.post(endpoint, params) }.to raise_error(Served::HTTPClient::ConnectionFailed)
      end

    end

    context '#delete' do

      it 'calls get with the expanded template' do
        expect(::HTTParty).to receive(:delete)
                                  .with(subject.template.expand(id: id, query: params, resource: endpoint).to_s,
                                        headers: resource.headers,
                                        timeout: resource.timeout)
                                  .and_return(response)
        subject.delete(endpoint, id, params)
      end

      it 'raises Served::HTTPClient::ConnecitonFailed when a connection failure occurs' do
        expect(::HTTParty).to receive(:delete).and_raise(Errno::ECONNREFUSED)
        expect { subject.delete(endpoint, id, params) }.to raise_error(Served::HTTPClient::ConnectionFailed)
      end

    end

  end

end