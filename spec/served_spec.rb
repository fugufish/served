require 'spec_helper'
describe Served do
  describe '#config' do
    describe '#timeout' do

      it 'defaults to 30' do
        expect(Served.config.timeout).to eq 30
      end
    end

  end
end