# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'implements long queries flow' do |method|
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }

  let(:connection) do
    Faraday.new do |builder|
      builder.adapter :test, stubs
    end
  end

  let(:http_method) { method.to_s.split(/long_/).last.to_sym }

  it 'sets \'Eyes-Date\' header' do
    expect(subject).to receive(:request) do |_url, _method, options|
      expect(options[:headers]).to include('Eyes-Date')
      expect(DateTime.parse(options[:headers]['Eyes-Date']).strftime('%a, %d %b %Y %H:%M:%S GMT')).to(
        eql(options[:headers]['Eyes-Date'])
      )
    end.and_return(a_200_result)
    subject.send(method, 'http://google.com', {}, 0)
  end

  it 'sets \'Eyes-Excpect\' header' do
    expect(subject).to receive(:request) do |_url, _method, options|
      expect(options[:headers]).to include('Eyes-Expect')
      expect(options[:headers]['Eyes-Expect']).to eql('202+location')
    end.and_return(a_200_result)
    subject.send(method, 'http://google.com', {}, 0)
  end

  describe 'on sucess:' do
    before do
      allow(Faraday::Connection).to receive(:new).with(any_args).and_return connection
    end

    it 'returns the result' do
      stubs.send(http_method, '/?apiKey') { |_env| [200, {}, 'simple_success'] }
      expect(subject.send(method, 'doesn\'t_matter', {}, 0).body).to eq('simple_success')
    end
  end

  describe 'on long task:' do
    it 'uses \'location\' header as a pull url' do
      allow(Faraday::Connection).to receive(:new).with(any_args).and_return connection
      stubs.send(http_method, '/?apiKey') do |_env|
        [202, { location: 'http://domain.com/pull' }, 'task is being processed']
      end
      expect(subject).to receive(:request).once.ordered.with('doesn\'t_matter', any_args).and_call_original
      expect(subject).to(
        receive(:request).once.ordered.with('http://domain.com/pull', any_args).and_return(a_strange_result)
      )
      begin
        subject.send(method, 'doesn\'t_matter', {}, 0)
      rescue Applitools::EyesError
        true
      end
    end

    it 'sets \'Eyes-Date\' header' do
      allow(Faraday::Connection).to receive(:new).with(any_args).and_return connection
      stubs.send(http_method, '/?apiKey') do |_env|
        [202, { location: 'http://domain.com/pull' }, 'task is being processed']
      end
      expect(subject).to receive(:request).once.ordered.with('doesn\'t_matter', any_args).and_call_original

      expect(subject).to receive(:request) do |_url, _method, options|
        expect(options[:headers]).to include('Eyes-Date')
        expect(DateTime.parse(options[:headers]['Eyes-Date']).strftime('%a, %d %b %Y %H:%M:%S GMT')).to(
          eql(options[:headers]['Eyes-Date'])
        )
      end.and_return(a_strange_result)
      begin
        subject.send(method, 'doesn\'t_matter', {}, 0)
      rescue Applitools::EyesError
        true
      end
    end

    describe 'pull' do
      before do
        allow(Faraday::Connection).to receive(:new).with(any_args).and_return connection
        stubs.send(http_method, '/?apiKey') do |_env|
          [202, { location: 'http://domain.com/pull' }, 'task is being processed']
        end
        expect(subject).to receive(:request).once.ordered.with('doesn\'t_matter', any_args).and_call_original
      end

      it 'raises an error on 410 response' do
        expect(subject).to receive(:request)
          .once.ordered.with('http://domain.com/pull', :get, any_args).and_return(a_gone_result)
        expect { subject.send(method, 'doesn\'t_matter', {}, 0) }.to raise_error Applitools::EyesError
      end
      it 'performs \'delete\' request on 201' do
        expect(subject).to(
          receive(:request).once.ordered.with('http://domain.com/pull', :get, any_args).and_return(a_completed_result)
        )
        expect(subject).to(
          receive(:request).once.ordered.with(
            'http://location.to.finish', :delete, hash_including(headers: hash_including('Eyes-Date'))
          ).and_return(a_200_result)
        )
        res = subject.send(method, 'doesn\'t_matter', {}, 0)
        expect(res.body).to eq 'Status: 200(For tests)'
      end
      it 'raises an exception if flow fails' do
        expect(subject).to(
          receive(:request).once.ordered.with('http://domain.com/pull', :get, any_args).and_return(a_strange_result)
        )
        expect { subject.send(method, 'doesn\'t_matter', {}, 0) }.to raise_error Applitools::EyesError
      end
    end
  end
end

describe Applitools::Connectivity::ServerConnector, clear_environment: true do
  it_behaves_like 'has environment attribute', :api_key, 'APPLITOOLS_API_KEY'
  let(:a_result) { Faraday::Response.new }
  let(:a_200_result) { a_result.dup.finish(status: 200, response_headers: {}, body: 'Status: 200(For tests)') }
  let(:a_gone_result) { a_result.dup.finish(status: 410, response_headers: {}, body: '') }
  let(:a_completed_result) do
    a_result.dup.finish(status: 201, response_headers: { location: 'http://location.to.finish' }, body: 'COMPLETED!')
  end
  let(:a_strange_result) { a_result.dup.finish(status: 255, response_headers: {}, body: 'STRANGE') }
  let(:an_internal_server_error) do
    a_result.dup.finish(status: 500, response_headers: {}, body: 'Status: 500(For tests)')
  end

  describe 'long methods' do
    it_behaves_like 'implements long queries flow', :long_post
    it_behaves_like 'implements long queries flow', :long_get
    it_behaves_like 'implements long queries flow', :long_delete
  end

  describe 'match_single_window_data' do
    before do
      Applitools::Connectivity::ServerConnector.class_eval do
        public :request_delay, :request
      end
      allow_any_instance_of(Applitools::MatchWindowData).to receive('screenshot').and_return ''
    end

    let(:data) { Applitools::MatchSingleCheckData.new }

    it 'increases retry delay' do
      delays = subject.send(:request_delay, 1, 2, 5).map(&:to_i)
      expect(delays).to contain_exactly 1, 2, 4
    end

    it 'calls itself on exception' do
      allow(subject).to receive('long_request') do
        raise Errno::EWOULDBLOCK.new 'message'
      end
      allow(subject).to receive('request_delay').and_return([0].to_enum)
      expect(subject).to receive('match_single_window_data').at_least(:twice).with(data).and_call_original
      expect { subject.match_single_window_data data }.to raise_error Applitools::UnknownNetworkStackError
    end

    it 'bubbles up Applitools::EyesError exception' do
      allow(subject).to receive('long_request').and_return an_internal_server_error
      expect { subject.match_single_window_data Applitools::MatchSingleCheckData.new }.to(
        raise_error Applitools::EyesError
      )
    end

    it 'resets @delays' do
      allow(subject).to receive('long_request') do
        raise Errno::EWOULDBLOCK.new 'message'
      end
      allow(subject).to receive('request_delay').and_return([0, 0, 0].to_enum)
      expect { subject.match_single_window_data data }.to raise_error Applitools::UnknownNetworkStackError
      expect(subject.instance_variable_get(:@delays)).to be nil
    end
  end

  describe 'request' do
    let(:req) do
      r = double
      allow(r).to receive(:options).and_return(opts)
      allow(r).to receive(:headers=)
      allow(r).to receive(:params=)
      allow(r).to receive(:body=)
      r
    end

    let(:opts) do
      r = double
      allow(r).to receive(:timeout=)
      r
    end
    before { allow_any_instance_of(Faraday::Connection).to receive(:get).and_yield(req) }

    it 'passes options[:headers] as headers' do
      expect(req).to receive(:headers=) do |value|
        expect(value).to include(:a => :b, :c => :d)
      end
      subject.send(:request, 'http://google.com', :get, headers: { :a => :b, :c => :d })
    end
    it 'sets content-type from options[:content_type]' do
      @hash = {}
      expect(req).to receive(:headers).and_return(@hash)
      subject.send(:request, 'http://google.com', :get, content_type: 'TestContentType')
      expect(@hash).to include('Content-Type' => 'TestContentType')
    end
    it 'passes default_headers' do
      @hash = {}
      allow(req).to receive(:headers=) do |v|
        @hash = v
      end
      allow(req).to receive(:headers).and_return(@hash)
      subject.send(:request, 'http://google.com', :get)
      expect(@hash).to include(Applitools::Connectivity::ServerConnector::DEFAULT_HEADERS)
    end
    it 'passes an api_key as a param' do
      @hash = {}
      allow(req).to receive(:params=) do |v|
        @hash = v
      end
      allow(req).to receive(:params).and_return(@hash)
      subject.api_key = 'API_KEY'
      subject.send(:request, 'http://google.com', :get)
      expect(@hash).to include(apiKey: 'API_KEY')
    end
    it 'sets body from options[:body]' do
      @body = nil
      expect(req).to receive(:body=) do |val|
        @body = val
      end
      subject.send(:request, 'http://google.com', :get, body: 'TestBODY')
      expect(@body).to eq 'TestBODY'
    end
  end
  describe 'responds to' do
    it_behaves_like 'responds to method', [
      :api_key,
      :api_key=,
      :server_url,
      :server_url=,
      :proxy=,
      :set_proxy,
      :start_session,
      :stop_session,
      :match_window,
      :match_single_window
    ]

    it_behaves_like 'has private method', [
      :long_get,
      :long_delete,
      :long_post,
      :get,
      :post,
      :delete
    ]

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
