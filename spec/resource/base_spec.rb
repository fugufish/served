require 'spec_helper'
describe Served::Resource::Base do
  let(:test_host) { 'http://testhost:3000' }

  let(:klass) {

    Class.new(Served::Resource::Base) do
      attribute :attr1
      attribute :attr2
      attribute :attr3

      headers({foo: :bar})
      headers({bar: :baz})

      def self.name
        'SomeModule::ResourceTest'
      end

      def self.parent
        Class.new do
          def self.name
            'SomeModule'
          end
        end
      end
    end
  }

  before :each do
    Served.configure do |c|
      c.hosts = {
          default: test_host
      }
    end
  end

  subject { klass }

  describe 'class methods' do
    before :all do
      Served.configure do |config|
        config.hosts = {
            'some_module' => 'http://testhost:3000'
        }
      end
    end

    context 'configuration' do

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

      describe '::client' do

        it 'creates a new connection instance' do
          expect(subject.client).to be_a(Served::HTTPClient)
        end

      end


      describe '::headers' do

        it 'sets the headers correctly' do
          expect(subject.headers[:foo]).to eq :bar
        end

        it 'merges calls to headers to existing headers' do
          expect(subject.headers[:foo]).to eq :bar
          expect(subject.headers[:bar]).to eq :baz
        end

        it 'sets the default JSON headers' do
          subject # avoids error preventing hash update during iteration
          Served::Resource::Base::HEADERS.each do |k, v|
            expect(subject.headers[k]).to eq v
          end
        end

      end
    end

    context 'resource model' do
      describe '::find' do

        let(:instance) { double(subject) }

        it 'creates a new instance of itself with the provided id and calls reload' do
          expect(subject).to receive(:new).with(id: 1).and_return(instance)
          expect(instance).to receive(:reload).and_return(true)
          subject.find(1)
        end

      end

      describe '.all' do
        let(:response) do
          [
            {
              attr1: 'Foo',
              attr2: 'FooBar',
            },
            {
              attr1: 'Boo',
              attr2: 'BooBar',
            }
          ]
        end
        let(:client) { double(get: response) }

        before do
          allow(subject).to receive(:client).and_return client
        end

        it 'parses the response into an array of instances' do
          ary = subject.all
          expect(ary.length).to eq 2
          expect(ary.first).to be_instance_of(klass)
          expect(ary.first.attr1).to eq response.first[:attr1]
        end
      end
    end
  end

  describe 'instance methods' do
    subject { klass.new({attr1: 1}) }
    let(:response) { {attr2: 2, attr3: 3} }

    context '#save' do


      it 'calls #put when an id is present' do
        subject.id = 1
        expect(subject).to receive(:put).and_return(response)
        expect(subject).to receive(:reload_with_attributes).and_return({subject.resource_name => response})
        subject.save
      end

      it 'calls #save when an id is not present' do
        expect(subject).to receive(:post).and_return(response)
        expect(subject).to receive(:reload_with_attributes).and_return({subject.resource_name => response})
        subject.save
      end

    end

    context '#reload' do

      it 'reloads with the response from get' do
        expect(subject).to receive(:get).and_return(response)
        expect(subject).to receive(:reload_with_attributes).with(response)
        subject.reload
      end

    end

    context '#destroy' do
      context 'response is a (204)' do
        let(:response) { double(code: 204) }
        before do
          allow_any_instance_of(Served::HTTPClient).to receive(:delete).and_return(response)
        end

        it 'returns true' do
          expect(subject.destroy).to be_truthy
        end
      end

      context 'response is success' do
        let(:body) { { attr2: 2, attr3: 3 }.stringify_keys }
        let(:response) { double(code: 202, body: body.to_json) }
        before do
          allow_any_instance_of(Served::HTTPClient).to receive(:delete).and_return(response)
        end

        it 'returns true' do
          expect(subject).to receive(:reload_with_attributes).with(body)
          subject.destroy
        end
      end
    end
  end
end
