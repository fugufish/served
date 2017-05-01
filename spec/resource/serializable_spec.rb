require 'spec_helper'
describe Served::Resource::Serializable do
  subject do
    Class.new do
      include Served::Resource::Serializable
      attribute :fixnum,  serialize: Fixnum
      attribute :string,  serialize: String
      attribute :symbol,  serialize: Symbol
      attribute :float,   serialize: Float
      attribute :boolean, serialize: Boolean

      def initialize(*args)
      end
    end
  end
  
  describe '::handle_response' do

    context 'default serializer' do

      let(:stub_serializer) {
        Class.new do
          extend Served.config.serializer
        end
      }

      let(:fake_200_response) {
        double('Response Object', code: 200, body: '{ "id": 1 }')
      }

      let(:fake_201_response) {
        double('Response Object', code: 201, body: '{ "id": 1 }')
      }

      describe '200 or 201' do
        it 'returns the result of serialize_response in the serializer' do
          expect(subject.send(:handle_response, fake_200_response))
             .to eq(stub_serializer.serialize_response(fake_200_response.body))
          expect(subject.send(:handle_response, fake_201_response))
             .to eq(stub_serializer.serialize_response(fake_201_response.body))
        end
      end

    end

  end

  describe 'SERIALIZERS' do

    context 'Fixnum' do
      it 'converts the value correctly' do
        expect(subject.new(fixnum: '1').fixnum).to eq 1
      end
    end

    context 'String' do
      it 'converts the value correctly' do
        expect(subject.new(string: 1).string).to eq '1'
      end
    end

    context 'Symbol' do
      it 'converts the value correctly' do
        expect(subject.new(symbol: 'test').symbol).to eq :test
      end

      it 'converts all elements of an array to symbols' do
        expect(subject.new(symbol: %w{a b c d e}).symbol).to eq [:a, :b, :c, :d, :e]
      end
    end

    context 'Float' do
      it 'converts the value correctly' do
        expect(subject.new(float: '1.1').float).to eq 1.1
      end
    end

    context 'Boolean' do
      it 'converts the value correctly' do
        expect(subject.new(boolean: 'true').boolean).to eq true
        expect(subject.new(boolean: 'false').boolean).to eq false
      end
    end

  end

end
