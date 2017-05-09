require 'spec_helper'
describe Served::Resource::Validatable do
  subject do
    Class.new do
      include Served::Resource::Validatable
      include Served::Resource::Serializable
      attribute :presence,     presence: true
      attribute :numericality, numericality: true
      attribute :format,       format: /[a-z]+/
      attribute :inclusion,    inclusion: { in: %w{foo bar}}
      attribute :nested,       presence: true,
                serialize: Class.new(Served::Attribute::Base) {
                  attribute :test, presence: true

                  def self.name
                    'Nested'
                  end
                }

      def self.name
        "TheClass"
      end

    end
  end

  describe 'validations' do

    it 'should validate presence' do
      instance = subject.new(presence: 'foo')
      instance.valid?
      expect(instance.errors[:presence]).to be_empty
      instance = subject.new
      instance.valid?
      expect(instance.errors[:presence]).to_not be_empty
    end

    it 'should validate numericality' do
      instance = subject.new(numericality: '1')
      instance.valid?
      expect(instance.errors[:numericality]).to be_empty
      instance = subject.new(numericality: 'a')
      instance.valid?
      expect(instance.errors[:numericality]).to_not be_empty
    end

    it 'should validate format' do
      instance = subject.new(format: 'abcd')
      instance.valid?
      expect(instance.errors[:format]).to be_empty
      instance = subject.new(format: '1234')
      instance.valid?
      expect(instance.errors[:format]).to_not be_empty
    end

    it 'should validate inclusion' do
      instance = subject.new(inclusion: 'foo')
      instance.valid?
      expect(instance.errors[:inclusion]).to be_empty
      instance = subject.new(inclusion: 'a')
      instance.valid?
      expect(instance.errors[:inclusion]).to_not be_empty
    end

    it 'should validate nested attributes' do
      instance = subject.new(nested: { test: 'foo'} )
      instance.valid?
      expect(instance.errors[:nested]).to be_empty
    end

  end
end
