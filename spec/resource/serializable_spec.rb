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

  describe '#to_json' do

    let(:instance) { subject.new }

    it 'converts the attributes to json format' do
      expect(instance.to_json).to eq(instance.attributes.to_json)
    end

    context 'custom presenter' do

      it 'returns the result of the presenter' do
        subject.redefine_method(:presenter) do
          {foo: 'bar'}
        end
        expect(instance.to_json).to eq({foo: 'bar'}.to_json)
      end
    end
  end

end
