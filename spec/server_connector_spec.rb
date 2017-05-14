require 'spec_helper'

describe Applitools::Connectivity::ServerConnector do
  describe 'responds to' do
    it 'api_key' do
      expect(subject).to respond_to :api_key, :api_key=
    end
    it 'server_url' do
      expect(subject).to respond_to :server_url, :server_url=
    end
    it 'proxy_settings' do
      expect(subject).to respond_to :proxy, :proxy=
    end
    it 'set_proxy' do
      expect(subject).to respond_to :set_proxy
      expect(subject).to receive :proxy=
      subject.set_proxy nil
    end
    it 'start_session' do
      expect(subject).to respond_to :start_session
    end
    it 'stop_session' do
      expect(subject).to respond_to :stop_session
    end
    it 'match_window' do
      expect(subject).to respond_to :match_window
    end

    describe 'checks proxy value' do
      it 'allows to set nil proxy' do
        expect { subject.proxy = nil }.to_not raise_error
      end

      it 'checks proxy class' do
        expect { subject.proxy = 'Invalid proxy' }.to raise_error Applitools::EyesIllegalArgument
      end
    end
  end

  describe Applitools::Connectivity::Proxy.new('http://google.com', 'user', 'password') do
    it_should_behave_like 'responds to method', [
      :to_hash,
      :uri,
      :user,
      :password
    ]

    describe 'passes parameters' do
      it 'uri' do
        expect(subject.to_hash).to include :uri
        expect(subject.to_hash[:uri].to_s).to eq('http://google.com')
      end

      it 'user' do
        expect(subject.to_hash).to include :user
        expect(subject.to_hash[:user]).to eq('user')
      end

      it 'password' do
        expect(subject.to_hash).to include :password
        expect(subject.to_hash[:password]).to eq('password')
      end

      it 'raises an exception for invalid uri' do
        expect { subject.uri = '::' }.to raise_error URI::InvalidURIError
      end
    end
  end

  describe 'request' do
    before do
      stub_const('Faraday::Connection', Object.new)
    end

    let(:foo) do
      Object.new.tap do |o|
        o.instance_eval do
          def post(*args); end
        end
      end
    end

    it 'passes proxy settings' do
      stub_const('Faraday::Connection', Object.new)

      expect(Faraday::Connection).to receive(:new) do |*opts|
        expect(opts.shift).to eq('http://google.com')
        expect(opts.last[:proxy][:uri]).to be_a(URI)
        expect(opts.last[:proxy][:uri].to_s).to eq 'http://localhost'
      end.and_return(foo)

      subject.set_proxy('http://localhost')
      subject.send 'post', 'http://google.com'
    end
  end
end
