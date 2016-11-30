require 'spec_helper'
describe Served::HTTPClient do
  subject { Served::HTTPClient.new('http://host', Served.config.timeout) }

  context 'with an addressable template' do
    subject { Served::HTTPClient.new('http://host/{resource}.foo', Served.config.timeout) }

     it 'does not use the default config template' do
       expect(subject.instance_variable_get(:@template).
         expand(resource: 'bar').to_s).to eq('http://host/bar.foo')
     end
  end

  # also tests the default template

  context '::HTTP backend' do
    describe '#get' do
      it 'calls the endpoint with the correct query and headers' do
        expect(::HTTP).to receive(:get)
                            .with('http://host/dir1/dir2/test/1.json?q=1',
                              headers: Served::HTTPClient::HEADERS,
                              timeout: Served.config.timeout
                            ).and_return(true)
        subject.get(%w(dir1 dir2 test), 1, { q: 1 })
      end
    end

    describe '#post' do
      it 'calls the endpoint with the correct query and headers' do
        expect(::HTTP).to receive(:post)
                            .with('http://host/test.json?q=1',
                              body:    { foo: :bar }.to_json,
                              headers: Served::HTTPClient::HEADERS,
                              timeout: Served.config.timeout
                            ).and_return(true)
        subject.post('test', { foo: :bar }.to_json, { q: 1 })
      end
    end

    describe '#put' do
      it 'calls the endpoint with the correct query and headers' do
        expect(::HTTP).to receive(:put).
          with(
            'http://host/test/1.json?q=1',
            body:    { foo: :bar }.to_json,
            headers: Served::HTTPClient::HEADERS,
            timeout: Served.config.timeout
          ).and_return(true)
        subject.put('test', 1, { foo: :bar }.to_json, { q: 1 })
      end
    end
  end



end
