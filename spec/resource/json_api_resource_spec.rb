# frozen_string_literal: true

require 'spec_helper'

class PeopleResource < Served::Resource::JsonApiResource
  attribute :name
  resource_name 'friends'
end

class AddressResource < Served::Resource::JsonApiResource
  attribute :id
  attribute :street
  attribute :city

  resource_name 'addresses'
end

class ServiceResource < Served::Resource::JsonApiResource
  attribute :id
  attribute :first_name, presence: true
  attribute :addresses, serialize: AddressResource
  attribute :friends, serialize: PeopleResource

  resource_name 'service_resource'
end

describe Served::Resource::JsonApiResource do
  let(:response) { double(body: body.to_json) }
  let(:client) { double(get: response) }

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

  describe 'post' do
    let(:client) { double(post: response) }
    let(:response) { double(body: error.to_json, code: 422) }

    before do
      allow(subject).to receive(:client).and_return client
      subject.save
    end

    context 'post returns a 422' do
      let(:error) do
        {
          errors: [
            {
              status: 422,
              title: 'Invalid Attribute',
              source: { pointer: '/data/attributes/first_name' },
              detail: 'must contain at least three characters.'
            }
          ]
        }
      end

      subject { ServiceResource.new(first_name: 'A') }

      before do
        allow(subject).to receive(:client).and_return client
        subject.save
      end

      it 'has an error on the attribute' do
        expect(subject.errors[:first_name]).to include error[:errors].first[:detail]
      end
    end

    context 'error with a non attribute message' do
      let(:error) do
        { errors: [
          {
            status: 422,
            title: 'Invalid Parameter',
            source: { parameter: 'warehouse_id' },
            detail: 'Warehouse id does not exist'
          }
        ] }
      end

      it 'has an error on base' do
        expect(subject.errors[:base]).to include error[:errors].first[:detail]
      end
    end

    context 'handles multiple error messages' do
      let(:error) do
        { errors: [
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
        ] }
      end

      it 'has multiple error messages' do
        expect(subject.errors.size).to eq 2
      end
    end

    context 'missing detail messages' do
      let(:error) do
        { errors: [
          {
            status: 422,
            title: 'Invalid request'
          }
        ] }
      end

      it 'sets the title as error message' do
        expect(subject.errors.full_messages).to include(error[:errors].first[:title])
      end
    end

    context 'wrong formatted error message' do
      let(:error) do
        { errors: [
          {
            error: 'Invalid request'
          }
        ] }
      end

      it 'sets a default error message if no title can be found' do
        expect(subject.errors.full_messages).to include('Error, but no error message found')
      end
    end

    context 'invalid json' do
      let(:error) { '<html>error</html>' }
      let(:response) { double(body: error, code: 422) }

      it 'handles invalid json and response' do
        expect(subject.errors.full_messages).to include('Service responded with an unparsable body')
      end
    end

    context 'success' do
      subject { ServiceResource.new(first_name: 'Fo') }
      let(:body) do
        {
          data:
            {
              id: 1,
              type: 'sorting-sections',
              attributes: {
                'first-name' => 'foobar'
              }
            }
        }
      end
      let(:response) { double(body: body.to_json, code: 200) }

      it 'successfully updates the attribute to the one of the response' do
        expect(subject.first_name).to eq 'foobar'
      end
    end
  end

  describe 'put' do
    subject { ServiceResource.new(first_name: 'Fo', id: 1) }
    let(:response) { double(body: body.to_json, code: 422) }
    let(:client) { double(put: response) }

    before do
      allow(subject).to receive(:client).and_return client
      subject.save
    end

    context 'returns a 422' do
      let(:body) do
        { errors: [
          {
            status: 422,
            title: 'Invalid Attribute',
            source: { pointer: '/data/attributes/first_name' },
            detail: 'must contain at least three characters.'
          }
        ] }
      end

      it 'has an error on the attribute' do
        expect(subject.errors[:first_name]).to include body[:errors].first[:detail]
      end
    end

    context 'success' do
      let(:body) do
        {
          data:
            {
              id: 1,
              type: 'sorting-sections',
              attributes: {
                'first-name' => 'foobar'
              }
            }
        }
      end
      let(:response) { double(body: body.to_json, code: 200) }

      it 'successfully updates the attribute to the one of the response' do
        expect(subject.first_name).to eq 'foobar'
      end
    end
  end

  describe '#destroy' do
    subject { ServiceResource.new(first_name: 'Fo', id: 1) }
    let(:response) { double(body: body.to_json, code: 422) }
    let(:client) { double(delete: response) }

    before do
      allow(subject).to receive(:client).and_return client
    end

    context 'returns a 422' do
      let(:body) do
        {
          errors: [
            {
              id: 'first-name',
              status: 422,
              title: 'Invalid Attribute',
              detail: "Couldn't find XYZ"
            }
          ]
        }
      end

      it 'returns false if an error is returned' do
        expect(subject.destroy).to be_falsey
      end

      it 'parses the error message' do
        subject.destroy
        expect(subject.errors[:base]).to include body[:errors].first[:detail]
      end
    end

    context 'success' do
      let(:body) do
        {
          data:
            {
              id: 1,
              type: 'sorting-sections',
              attributes: {
                'first-name' => 'foobar'
              }
            }
        }
      end
      let(:response) { double(body: body.to_json, code: 200) }

      it 'returns true if successful' do
        expect(subject.destroy).to eq true
      end
    end
  end

  describe '.all' do
    let(:body) do
      {
        data:
          [
            {
              id: 1,
              type: 'sorting-sections',
              attributes: {
                'first-name' => 'foobar'
              }
            },
            {
              id: 2,
              type: 'sorting-sections',
              attributes: {
                'first-name' => 'boobar'
              }
            }

          ]
      }
    end

    subject { ServiceResource }

    before do
      allow(subject).to receive(:client).and_return client
    end

    it 'parses the response into an array of instances' do
      ary = subject.all
      expect(ary.length).to eq 2
      expect(ary.first).to be_instance_of(ServiceResource)
      expect(ary.first.first_name).to eq body[:data].first[:attributes]['first-name']
      expect(ary.first.id).to eq body[:data].first[:id]
    end
  end

  describe 'nested resource' do
    let(:response) { double(body: body.to_json, code: 200) }
    let(:client) { double(get: response) }

    before do
      allow(subject).to receive(:client).and_return client
    end

    subject { ServiceResource }

    context 'single nested resource' do
      let(:body) do
        {
          data: {
            id: 1,
            type: 'sorting-sections',
            attributes: {
              'first-name' => 'foobar'
            },
            relationships: {
              addresses: {
                data: {
                  id: 1,
                  type: 'addresses',
                  attributes: {
                    street: 'Broadway',
                    city: 'New York'
                  }
                }
              }
            }
          }
        }
      end

      it 'parses the nested relationship' do
        resource = subject.find(1)
        expect(resource).to be_instance_of(ServiceResource)
        expect(resource.addresses).to be_instance_of(AddressResource)
        expect(resource.addresses.street).to eq 'Broadway'
      end
    end

    context 'nested resource data array' do
      let(:body) do
        {
          data: {
            id: 1,
            type: 'customer',
            attributes: {
              'first-name' => 'foobar'
            },
            relationships: {
              addresses: {
                data: [
                  {
                    id: 1,
                    type: 'addresses',
                    attributes: {
                      street: 'Broadway',
                      city: 'New York'
                    }
                  },
                  {
                    id: 2,
                    type: 'addresses',
                    attributes: {
                      street: 'Main St',
                      city: 'Baltimore'
                    }
                  }
                ]
              },
              friends: {
                data: [
                  {
                    id: 1,
                    type: 'people',
                    attributes: {
                      name: 'Ruby'
                    }
                  }
                ]
              }
            }
          }
        }
      end

      it 'parses the nested relationships' do
        resource = subject.find(1)
        expect(resource).to be_instance_of(ServiceResource)
        expect(resource.addresses).to be_instance_of(Array)
        expect(resource.addresses.first).to be_instance_of(AddressResource)
        expect(resource.addresses.first.street).to eq 'Broadway'
        expect(resource.friends).to be_instance_of(Array)
        expect(resource.friends.first).to be_instance_of(PeopleResource)
        expect(resource.friends.first.name).to eq 'Ruby'
      end
    end

    context 'empty nested resource data array' do
      let(:body) do
        {
          data: {
            id: 1,
            type: 'customer',
            attributes: {
              'first-name' => 'foobar'
            },
            relationships: {
              addresses: {
                data: []
              }
            }
          }
        }
      end

      it 'returns an empty array' do
        resource = subject.find(1)
        expect(resource.addresses).to eq []
      end
    end

  end
end
