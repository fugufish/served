require 'spec_helper'

class ServiceResource < Served::Resource::JsonApiResource
  attribute :id
  attribute :first_name, presence: true
end

describe Served::Resource::JsonApiResource do
  before :all do
    Served.configure do |config|
      config.hosts = {
        'some_module' => 'http://testhost:3000'
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
    let(:client) { double(post: response)}
    let(:response) { double({body: error.to_json, code: 422}) }

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

      it 'has multiple error messages' do
        expect(subject.valid?).to be_falsey
      end
    end
  end
end
