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
    ].to_json
  end
  let(:unparseable) { '<html></html>' }

  let(:response) {  double({body: errors}) }
  let(:invalid_response) {  double({body: unparseable, code: 500}) }


  describe 'parsing' do
    subject { described_class.new(response) }
    it 'creates new error objects' do
      expect(subject.first).to be_an_instance_of(Served::JsonApiError::Error)
    end

    it 'returns size of errors' do
      expect(subject.errors.size).to eq JSON.parse(errors).size
    end
  end

  describe 'unparseable response' do
    subject { described_class.new(invalid_response) }

    it 'rescues the error and creates a custom error object' do
      expect(subject.errors.first.title).to eq 'Parsing Error'
    end
  end
end
