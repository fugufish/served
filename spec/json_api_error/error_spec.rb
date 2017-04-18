require 'spec_helper'

describe Served::JsonApiError::Error do
  let(:basic_422) do
        {
          id: 67,
          code: '123',
          status: 422,
          source: { pointer: '/data/attributes/first-name', parameter: 'include' },
          title: 'Invalid Attribute',
          detail: 'First name must contain at least three characters.'
        }
  end

  subject { described_class.new(basic_422) }

  describe 'accessible attributes' do
    it 'title' do
      expect(subject.title).to eq basic_422[:title]
    end

    it 'status' do
      expect(subject.status).to eq basic_422[:status]
    end

    it 'code' do
      expect(subject.code).to eq basic_422[:code]
    end

    it 'detail' do
      expect(subject.detail).to eq basic_422[:detail]
    end

    it 'id' do
      expect(subject.id).to eq basic_422[:id]
    end

    it 'source_pointer' do
      expect(subject.source_pointer).to eq basic_422[:source][:pointer]
    end

    it 'source_parameter' do
      expect(subject.source_parameter).to eq basic_422[:source][:parameter]
    end
  end
end
