require 'spec_helper'
describe Served::Resource::Attributable do
  subject do
    Class.new do
      include Served::Resource::Attributable

      def initialize(*args)
      end

    end
  end

  context '::attribute' do
    it 'provides the ability to define an attribute' do
      subject.attribute :foo
      expect(subject.attributes[:foo]).to_not be_nil
      expect(subject.attributes[:bar]).to be_nil
    end

    it 'writes the options passed to ::attribute' do
      subject.attribute :foo, default: 'bar'
      expect(subject.attributes[:foo][:default]).to eq 'bar'
    end
  end

  context '#new' do

    it 'creates a new instance and assigns the given attributes' do
      subject.attribute :foo
      expect(subject.new(foo: 'bar').foo).to eq 'bar'
    end

    it 'uses the default if the attribute was undefined' do
      subject.attribute :foo, default: 'bar'
      expect(subject.new.foo).to eq 'bar'
    end

  end

end
