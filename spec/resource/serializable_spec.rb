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

  it 'sets the default serializer to json' do
    expect(subject.serializer).to eq(Served::Serializers::Json)
  end

  describe '::from_hash' do

    let(:hash) { { fixnum: "1", string: 1, symbol: "foo", float: '0.1', boolean: 'false' } }

    it 'loads the data in the given string using the provided serializer' do
      expect { subject.from_hash(hash) }.to_not raise_exception
    end

    it 'correctly loads fixnums' do
      expect(subject.from_hash(hash)[:fixnum]).to eq(1)
    end

    it 'correctly loads strings' do
      expect(subject.from_hash(hash)[:string]).to eq('1')
    end

    it 'correctly loads symbols' do
      expect(subject.from_hash(hash)[:symbol]).to eq(:foo)
    end

  end

  describe '::load' do

    it 'uses the serializer to load the provided string' do
      expect(subject.serializer).to receive(:load).and_return({})
      expect { subject.load('{}') }.to_not raise_exception
    end

    it 'throws an appropriate error when a response fails to load' do
      expect(subject.serializer).to receive(:load).and_raise('An Error')
      expect { subject.load('') }.to raise_error(Served::Resource::ResponseInvalid)
    end

  end

end
