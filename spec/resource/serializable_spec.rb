require 'spec_helper'
describe Served::Resource::Serializable do

  let!(:attr) {
    Class.new(Served::Attribute::Base) do
      attribute :test
    end
  }

  subject do
    Class.new do
      class Attr < Served::Attribute::Base
        attribute :test, serialize: :string
      end

      include Served::Resource::Serializable
      attribute :fixnum,  serialize: Fixnum
      attribute :string,  serialize: String
      attribute :symbol,  serialize: Symbol
      attribute :float,   serialize: Float
      attribute :boolean, serialize: Boolean
      attribute :attr,    serialize: Class.new(Served::Attribute::Base) { attribute :test }
      attribute :arry,    serialize: Class.new(Served::Attribute::Base) { attribute :test }
      attribute :null,    serialize: Integer

    end
  end



  it 'sets the default serializer to json' do
    expect(subject.serializer).to eq(Served::Serializers::Json)
  end

  describe '::from_hash' do

    let(:hash) do
      { fixnum: '1',
        string: 1,
        symbol: 'foo',
        float: '0.1',
        boolean: 'false',
        attr: { test: 'string' },
        arry: [{ test: 'string' }, { test: 'another string' }],
        null: nil
      }
    end

    it 'returns nil if it cannot convert' do
      expect { subject.from_hash(hash)[:null].to eq(nil) }
    end

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

    it 'correctly loads resource attributes' do
      expect(subject.from_hash(hash)[:attr].class).to eq(subject.attributes[:attr][:serialize])
    end

    it 'correctly loads array instances' do
      expect(subject.from_hash(hash)[:arry].first.class).to eq(subject.attributes[:arry][:serialize])
    end

    describe 'invalid attribute serializer' do

      subject do
        class Invalid;end
        Class.new do
          include Served::Resource::Serializable
          attribute :invalid,  serialize: Invalid

          def initialize(*args)
          end
        end
      end

      let(:hash) { { invalid: 'invalid' } }

      it 'raises an invalid attribute serializer exception' do
        expect { subject.from_hash(hash) }.to raise_error(Served::Resource::InvalidAttributeSerializer)
      end

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
