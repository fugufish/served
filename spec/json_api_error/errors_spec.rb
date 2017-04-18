require 'spec_helper'

describe Served::JsonApiError::Errors do
  let(:errors) do
    [
      {
        id: 67,
        code: '123',
        status: 422,
        source: { pointer: '/data/attributes/first-name', parameter: 'include' },
        title: 'Invalid Attribute',
        detail: 'First name must contain at least three characters.'
      },
      {
        id: 67,
        code: '123',
        status: 422,
        source: { pointer: '/data/attributes/first-name', parameter: 'include' },
        title: 'Invalid Attribute',
        detail: 'First name must contain at least three characters.'
      }
    ]
  end

  subject { described_class.new(errors) }

  describe 'parsing' do
    it 'creates new error objects' do
      expect(subject.first).to be_an_instance_of(Served::JsonApiError::Error)
    end

    it 'returns size of errors' do
      expect(subject.errors.size).to eq errors.size
    end
  end
end
