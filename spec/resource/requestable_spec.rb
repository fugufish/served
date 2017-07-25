require 'spec_helper'
describe Served::Resource::Base do
  let(:test_host) { 'http://testhost:3000' }
  let(:body) { '{"id": 1, "first_name": "Foo"}' }
  let(:response_code) { 200 }
  let(:response) { double(body: body, code: response_code) }
  let(:client) { double(get: response) }

  let(:klass) do
    Class.new(Served::Resource::Base) do
      attribute :id
      attribute :first_name

      def self.name
        'SomeModule::ResourceTest'
      end
    end
  end

  class JsonApiResource < Served::Resource::Base
    def self.raise_on_exceptions
      false
    end
  end

  before :each do
    Served.configure do |c|
      c.hosts = { default: test_host }
    end
  end

  subject { klass }

  describe '#handle_response' do
    describe '200' do
      it 'calls load' do
        expect(subject).to receive(:load)
        subject.handle_response(response)
      end
    end

    describe '204' do
      let(:response_code) { 204 }

      it 'returns attributes' do
        expect(subject.handle_response(response)).to eq(id: {})
      end
    end

    describe 'error codes' do
      let(:response_code) { 301 }

      it 'raises an exception' do
        expect do
          subject.handle_response(response)
        end.to raise_exception Served::Resource::MovedPermanently
      end

      context 'with an empty response body' do
        let(:response_code) { 408 }
        let(:response) { double(body: '', code: response_code) }

        it 'raises an exception' do
          expect do
            subject.handle_response(response)
          end.to raise_exception Served::Resource::RequestTimeout
        end
      end
    end

    describe 'generic error codes' do
      let(:response_code) { 504 }

      it 'raises an exception' do
        expect do
          subject.handle_response(response)
        end.to raise_exception Served::Resource::ServerError
      end
    end

    describe 'do not raise on exceptions' do
      let(:response_code) { 301 }
      subject { JsonApiResource }

      it 'raises an exception' do
        expect(subject.serializer).to receive(:load)
        subject.handle_response(response)
      end
    end
  end
end
