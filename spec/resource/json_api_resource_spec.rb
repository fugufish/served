require 'spec_helper'

class ServiceResource < Served::Resource::JsonApiResource
  attribute :id
  attribute :first_name, presence: true

  resource_name 'service_resource'
end

describe Served::Resource::JsonApiResource do
  before :all do
    Served.configure do |config|
      config.hosts = {
        'service_resource' => 'http://testhost:3000'
      }
    end
  end

  describe '#validations' do
    context 'invalid' do
      subject { ServiceResource.new }

      it 'is invalid without name' do
        expect(subject.valid?).to be_falsey
      end
    end

    context 'invalid' do
      subject { ServiceResource.new(first_name: 'FooBar') }

      it 'is valid with a name' do
        expect(subject.valid?).to be_truthy
      end
    end
  end

  describe 'service error' do
    describe 'post' do
      let(:client) { double(post: response) }
      let(:response) { double({ body: error.to_json, code: 422 }) }

      before do
        allow(subject).to receive(:client).and_return client
        subject.save
      end

      context 'post returns a 422' do
        let(:error) do
          [
            {
              status: 422,
              title: 'Invalid Attribute',
              source: { pointer: '/data/attributes/first_name' },
              detail: 'must contain at least three characters.'
            }
          ]
        end

        subject { ServiceResource.new(first_name: 'A') }

        before do
          allow(subject).to receive(:client).and_return client
          subject.save
        end

        it 'has an error on the attribute' do
          expect(subject.errors[:first_name]).to include error.first[:detail]
        end
      end

      context 'error with a non attribute message' do
        let(:error) do
          [
            {
              status: 422,
              title: 'Invalid Parameter',
              source: { parameter: 'warehouse_id' },
              detail: 'Warehouse id does not exist'
            }
          ]
        end

        it 'has an error on base' do
          expect(subject.errors[:base]).to include error.first[:detail]
        end
      end

      context 'handles multiple error messages' do
        let(:error) do
          [
            {
              status: 422,
              title: 'Invalid Attribute',
              source: { pointer: '/data/attributes/first_name' },
              detail: 'must contain at least three characters.'
            },
            {
              status: 422,
              title: 'Invalid Parameter',
              source: { parameter: 'warehouse_id' },
              detail: 'Warehouse id does not exist'
            }
          ]
        end

        it 'has multiple error messages' do
          expect(subject.errors.size).to eq 2
        end
      end

      context 'missing detail messages' do
        let(:error) do
          [
            {
              status: 422,
              title: 'Invalid request'
            }
          ]
        end

        it 'sets the title as error message' do
          expect(subject.errors.full_messages).to include(error.first[:title])
        end
      end

      context 'wrong formatted error message' do
        let(:error) do
          [
            {
              error: 'Invalid request'
            }
          ]
        end

        it 'sets a default error message if no title can be found' do
          expect(subject.errors.full_messages).to include('Error, but no error message found')
        end
      end

      context 'invalid json' do
        let(:error) { '<html>error</html>' }
        let(:response) { double({ body: error, code: 422 }) }

        it 'handles invalid json and response' do
          expect(subject.errors.full_messages).to include('Service responded with an unparsable body')
        end
      end

      context 'success' do
        subject { ServiceResource.new(first_name: 'Fo') }
        let(:body) { { service_resource: { id: 1, first_name: 'foobar' } }}
        let(:response) { double({ body: body.to_json, code: 200 }) }

        it 'successfully updates the attribute to the one of the response' do
          expect(subject.first_name).to eq 'foobar'
        end
      end
    end

    describe 'put' do
      subject { ServiceResource.new(first_name: 'Fo', id: 1) }
      let(:response) { double({ body: body.to_json, code: 422 }) }
      let(:client) { double(put: response) }

      before do
        allow(subject).to receive(:client).and_return client
        subject.save
      end

      context 'returns a 422' do
        let(:body) do
          [
            {
              status: 422,
              title: 'Invalid Attribute',
              source: { pointer: '/data/attributes/first_name' },
              detail: 'must contain at least three characters.'
            }
          ]
        end

        it 'has an error on the attribute' do
          expect(subject.errors[:first_name]).to include body.first[:detail]
        end
      end

      context 'success' do
        let(:body) { { service_resource: { id: 1, first_name: 'foobar' } }}
        let(:response) { double({ body: body.to_json, code: 200 }) }

        it 'successfully updates the attribute to the one of the response' do
          expect(subject.first_name).to eq 'foobar'
        end
      end
    end
  end
end
