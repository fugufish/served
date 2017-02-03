require 'spec_helper'
describe Served::Resource::Base do
  let(:test_host) { 'http://testhost:3000' }

  describe 'class methods' do
    before :all do
      Served.configure do |config|
        config.hosts = {
            'some_module' => 'http://testhost:3000'
        }
      end
    end

    after :each do
      Served.send(:remove_const, :SomeModule)
    end

    subject {

      module Served
        module SomeModule
          # Test class
          class ResourceTest < Served::Resource::Base
            attribute :test
            attribute :test_with_default, default: 'test'
          end
        end
      end
      Served::SomeModule::ResourceTest
    }

    describe '::attribute' do

      it 'adds the attribute to the attribute list and creates an attr_accessor' do
        expect(subject.attributes.include?(:test)).to be true
        expect(subject.new).to respond_to(:test)
        expect(subject.new).to respond_to(:test=)
      end

      it 'sets the default value if the default option is present' do
        expect(subject.new.test_with_default).to eq('test')
      end

    end

    describe '::resource_name' do

      it 'returns the tableized name of the class' do
        expect(subject.resource_name).to eq 'resource_tests'
      end

    end

    describe '::host' do

      it 'returns the url for SomeModule host' do
        expect(subject.host).to eq test_host
      end

    end

    describe '::connection' do

      it 'creates a new connection instance' do
        expect(subject.client).to be_a(Served::HTTPClient)
      end

    end

    describe '::find' do

      let(:instance) { double(subject) }

      it 'creates a new instance of itself with the provided id and calls reload' do
        subject.find(1)
      end

    end

  end

  describe 'instance methods' do

    before :all do
      Served.configure do |config|
        config.hosts = {
            'some_module' => 'http://testhost:3000'
        }
      end
    end

    after :each do
      Served.send(:remove_const, :SomeModule)
    end

    let(:klass) {
      module Served
        module SomeModule
          # Test class
          class ResourceTest < Served::Resource::Base
            attribute :attr1
            attribute :attr2
            attribute :attr3
          end
        end
      end
      Served::SomeModule::ResourceTest
    }

    describe '#initialize' do

      it 'should initialize and set the attributes passed to #new' do
        subject = klass.new(attr1: 1, attr2: 2)
        expect(subject.attr1).to eq 1
        expect(subject.attr2).to eq 2
      end

    end

    describe '#to_json' do
      context 'with presenter' do

        let(:klass) {
          module Served
            module SomeModule
              # Test class
              class ResourceTest < Served::Resource::Base
                attribute :attr1
                attribute :attr2
                attribute :attr3

                def presenter
                  {attr1: 1}
                end
              end
            end
          end
          Served::SomeModule::ResourceTest
        }

        it 'returns the results of the presenter' do
          expect(klass.new(attr1: 1, attr2: 2).to_json).to eq({attr1: 1}.to_json)
        end

      end

      context 'without presenter' do
        let(:klass) {
          module Served
            module SomeModule
              # Test class
              class ResourceTest < Served::Resource::Base
                attribute :attr1
                attribute :attr2
                attribute :attr3
              end
            end
          end
          Served::SomeModule::ResourceTest
        }

        it 'returns there results of the serialized attributes' do
          expect(klass.new(attr1: 1, attr2: 2).to_json)
              .to eq({klass.resource_name.singularize => {id: nil, attr1: 1, attr2: 2, attr3: nil}}.to_json)
        end
      end
    end

    describe '#save' do

      context 'new record' do

        subject { klass.new(attr1: 1) }

        let(:response) { {subject.resource_name.singularize => {attr1: 1}} }

        it 'calls reload_with_attributes with the result of  post with the  current attributes' do
          expect(subject).to receive(:post)
                                 .and_return(response)
          expect(subject).to receive(:reload_with_attributes).with(response[subject.resource_name.singularize])
          expect(subject.save).to eq true
        end

      end

      context 'existing record' do

        subject { klass.new(id: 1, attr1: 1) }

        let(:response) { {klass.resource_name.singularize => {id: 1, attr1: 1}} }

        it 'calls reload_with_attributes with the result of  post with the  current attributes' do
          expect(subject).to receive(:put).and_return(response)
          expect(subject).to receive(:reload_with_attributes).with(response[klass.resource_name.singularize])
          subject.save
        end

      end

    end

    describe '#get' do

      subject { klass.new(id: 1) }
      let(:response) { double('Response', body: {klass.resource_name.singularize => {id: 1, attr1: 1}}, code: 200) }

      it 'calls #handle_response with the result of the GET request' do
        expect(subject).to receive(:handle_response).with(response)
        expect(klass.client).to receive(:get).with(klass.resource_name, 1, {}).and_return(response)
        subject.send(:get)
      end

    end

    # TODO: This feature potentially breaks backwards compatibility, will add in 0.2.0

    # describe '#put' do
    #   subject { klass.new(id: 1, attr1: 'foo') }
    #   let(:response) { double('Response', body: { klass.resource_name.singularize => { id: 1, attr1: 1 } }, code: 200) }
    #
    #   it 'calls client.put passing the id, but without passing id in the body using the default serializer' do
    #     expect(subject).to receive(:handle_response).with(response)
    #     expect(klass.client).to receive(:put).
    #       with(
    #         klass.resource_name,
    #         subject.id,
    #         { klass.resource_name.singularize => {id: 1, attr1: 'foo', attr2: nil, attr3: nil}}.to_json,
    #         {}
    #       ).
    #       and_return(response)
    #     subject.send(:put)
    #   end
    # end


    describe 'Validations' do

      let(:klass) {
        module Served
          module SomeModule
            # Test class
            class ResourceTest < Served::Resource::Base
              ALLOWED = %w{a b c d}
              attribute :attr1, presence: true
              attribute :attr2, numericality: true
              attribute :attr3, format: {with: /[a-z]+/}
              attribute :attr4

              def presenter
                {attr1: 1}
              end


              validates_each :attr4 do |record, _, value|
                invalid = (value - ALLOWED) if value
                unless invalid.blank?
                  record.errors.add(:attr4, :invalid)
                end
              end
            end
          end
        end
        Served::SomeModule::ResourceTest
      }

      it 'validates presence' do
        k = klass.new(attr2: 1, attr3: 'foo')
        expect(k.valid?).to be_falsey
        expect(k.errors[:attr1]).to_not be_blank
      end

      it 'validates numericality' do
        k = klass.new(attr1: 1, attr2: 'foo', attr3: 'foo')
        expect(k.valid?).to be_falsey
        expect(k.errors[:attr2]).to_not be_blank
      end

      it 'validates format' do
        k = klass.new(attr1: 1, attr2: 1, attr3: 1)
        expect(k.valid?).to be_falsey
        expect(k.errors[:attr3]).to_not be_blank
      end

      it 'validates with custom validator' do
        k = klass.new(attr1: 1, attr2: 1, attr3: 'foo', attr4: [1, 'b', 'c'])
        expect(k.valid?).to be_falsey
      end

      it 'passes all validations' do
        k = klass.new(attr1: 1, attr2: 1, attr3: 'foo')
        expect(k.valid?).to be_truthy
        expect(k.errors[:attr1]).to be_blank
        expect(k.errors[:attr2]).to be_blank
        expect(k.errors[:attr3]).to be_blank
      end

    end

    describe 'serialization' do

      let!(:subklass) {
        module Served
          module SomeModule
            # Test class
            class ResourceSub < Served::Attribute::Base
              attribute :sub_attr, presence: true
            end
          end
        end
        Served::SomeModule::ResourceSub
      }


      let!(:thing) {
        module Served
          module SomeModule
            class Thing
              def initialize(options={})
              end
            end
          end
        end
        Served::SomeModule::Thing
      }

      let(:klass) {
        module Served
          module SomeModule
            # Test class
            class ResourceTest < Served::Resource::Base
              attribute :attr, presence: true, serialize: Served::SomeModule::ResourceSub
              attribute :fixnum,               serialize: Fixnum
              attribute :thing,                serialize: Served::SomeModule::Thing
              attribute :stuff

            end
          end
        end
        Served::SomeModule::ResourceTest
      }



      it 'validates the invalid sub class when validating' do
        k = klass.new(attr: {})
        expect(k.valid?).to be_falsey
        expect(k.errors[:attr]).to_not be_empty
      end

      it 'validates the valid sub class when validating' do
        k = klass.new(attr: { sub_attr: 'foo' })
        expect(k.valid?).to be_truthy
        expect(k.errors[:attr]).to be_empty
      end

      it 'correctly serializes as a Fixnum' do
        k = klass.new(fixnum: '1')
        expect(k.fixnum).to be_a Fixnum
      end

      it 'serializes a value with the class provided to the :serialize option' do
        k = klass.new(thing: 'thing')
        expect(k.thing).to be_a thing
      end

      context 'receives undefined attribute' do

        it 'ignores attributes passed in that are not defined' do
          expect { klass.new(not_a_thing: 1) }.to_not raise_erro
        end

      end

    end

    describe '#handle_response' do

      it 'raises an error when code is not in the 200 range' do
        expect { klass.new.send(:handle_response, double('Response', code: 500)) }.
            to raise_error(Served::Resource::Base::ServiceError)
      end

    end
  end
end