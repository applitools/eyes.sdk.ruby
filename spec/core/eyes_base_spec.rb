require 'spec_helper'

describe Applitools::EyesBase do
  it_should_behave_like 'responds to method', [
    :agent_id,
    :agent_id=,
    :api_key,
    :api_key=,
    :server_url,
    :server_url=,
    :proxy, :proxy=,
    :disabled?,
    :disabled=,
    :app_name,
    :app_name=,
    :branch_name,
    :branch_name=,
    :parent_branch_name,
    :parent_branch_name=,
    :match_timeout,
    :match_timeout=,
    :save_new_tests,
    :save_new_tests=,
    :save_failed_tests,
    :save_failed_tests=,
    :batch,
    :batch=,
    :failure_reports,
    :failure_reports=,
    :open?,
    :log_handler,
    :log_handler=,
    :scale_ratio,
    :scale_ratio=,
    :close,
    :abort_if_not_closed,
    :host_os,
    :host_os=,
    :host_app,
    :host_app=,
    :base_line_name,
    :base_line_name=,
    :position_provider,
    :position_provider=,
    :open_base,
    :check_window_base,
    :cut_provider,
    :cut_provider=,
    :default_match_settings,
    :default_match_settings=,
    :add_property
  ]

  it_should_behave_like 'has private method', [
    :clear_user_inputs,
    :user_inputs,
    :start_session,
    :base_agent_id,
    :update_default_settings
    # :close_response_time
  ]

  it_should_behave_like 'proxy to object method', :server_connector, [
    :api_key,
    :api_key=,
    :server_url,
    :server_url=,
    :proxy,
    :proxy=,
    :set_proxy
  ]

  it_should_behave_like 'proxy method', Applitools::EyesLogger, [:logger, :log_handler, :log_handler=]

  it_should_behave_like 'has abstract method', [:base_agent_id]

  it 'initializes variables' do
    expect(subject.send(:disabled?)).to eq false
    expect(subject.instance_variable_get(:@viewport_size)).to be_nil
    expect(subject.send(:running_session)).to be_nil
    expect(subject.send(:last_screenshot)).to be_nil
    expect(subject.send(:agent_id)).to be_nil
    expect(subject.send(:save_new_tests)).to eq true
    expect(subject.send(:save_failed_tests)).to eq false
    expect(subject.send(:match_timeout)).to eq Applitools::EyesBase::DEFAULT_MATCH_TIMEOUT
  end

  context ':set_default_settings' do
    let(:data) { Applitools::MatchWindowData.new }
    it 'iterates over keys' do
      %w(match_level exact scale remainder).each do |k|
        expect_any_instance_of(Applitools::MatchWindowData).to(
          receive("#{k}=").with(subject.default_match_settings[k.to_sym])
        )
      end
      subject.send('update_default_settings', data)
    end
  end

  context ':default_match_settings' do
    it 'returns Hash' do
      expect(subject.default_match_settings).to be_a Hash
    end
    it 'has default value' do
      expect(subject.default_match_settings.keys).to(
        contain_exactly(*%w(match_level exact scale remainder).map(&:to_sym))
      )
      expect(subject.server_scale).to eq 0
      expect(subject.server_remainder).to eq 0
      expect(subject.exact).to be nil
      expect(subject.match_level).to eq Applitools::MATCH_LEVEL[:strict]
    end
    it 'sets match level before tests' do
      subject.set_default_match_settings(:layout)
      expect(subject.default_match_settings).to include(match_level: 'Layout')
      subject.set_default_match_settings(:strict)
      expect(subject.default_match_settings).to include(match_level: 'Strict')
    end
  end

  context ':default_match_settings=' do
    it 'accepts hash as an argument' do
      expect { subject.default_match_settings = {} }.to_not raise_error
      expect { subject.default_match_settings = 'invalid' }.to raise_error Applitools::EyesError
    end
    it 'raises an error when value contains extra keys' do
      expect { subject.default_match_settings = { extra_key: 'none' } }.to raise_error Applitools::EyesError
      expect { subject.default_match_settings = { match_level: 'none' } }.to_not raise_error
    end
    it 'merges passed value to default_match_settings' do
      expect(subject).to receive(:match_level=).with('match_level')
      expect(subject).to receive(:exact=).with('exact')
      expect(subject).to receive(:server_scale=).with('server_scale')
      expect(subject).to receive(:server_remainder=).with('server_remainder')
      subject.default_match_settings = {
        match_level: 'match_level',
        exact: 'exact',
        scale: 'server_scale',
        remainder: 'server_remainder'
      }
    end
  end

  context 'add_property' do
    it 'add_property adds a hash to properties array' do
      expect(subject.instance_variable_get(:@properties)).to be_a Array
      expect(subject.instance_variable_get(:@properties)).to be_empty
      subject.add_property :a, :b
      expect(subject.instance_variable_get(:@properties).first).to be_a Hash
      expect(subject.instance_variable_get(:@properties).first).to include :name => :a, :value => :b
    end
    it 'passes properties array to start_session' do
      allow(subject).to receive(:get_viewport_size).and_return({})
      allow(subject).to receive(:base_agent_id).and_return({})
      expect(Applitools::SessionStartInfo).to receive(:new) do |*args|
        expect(args.first).to be_a Hash
        expect(args.first).to include :properties
        expect(args.first[:properties]).to eq subject.send(:properties)
      end.and_return nil
      subject.send(:start_session)
    end
  end

  context 'abort_if_not_closed' do
    it_behaves_like 'can be disabled', :abort_if_not_closed
    context do
      before do
        expect(subject).to receive(:disabled?).and_return false
        allow_any_instance_of(Applitools::Connectivity::ServerConnector).to receive(:stop_session).and_return true
        subject.server_url = nil
        subject.send(:running_session=, Applitools::Session.new('id', 'url', true))
      end

      after do
        subject.abort_if_not_closed
      end

      it 'calls ServerConnector.stop_session' do
      end

      it 'clears user inputs' do
        expect(subject).to receive :clear_user_inputs
      end

      it 'clears last screenshot' do
        expect(subject).to receive(:last_screenshot=).with(nil)
      end

      it 'drops running session' do
        expect(subject).to receive(:running_session=).with(nil)
      end
    end
  end

  context 'open_base()' do
    before do
      allow(subject).to receive(:base_agent_id).and_return nil
      allow(subject).to receive(:get_viewport_size).and_return(width: 800, height: 600)
      allow(subject).to receive(:app_environment).and_return(
        Applitools::AppEnvironment.new(
          :os => :host_os,
          :hosting_app => :host_app,
          :display_size => Applitools::RectangleSize.new(800, 600),
          :inferred => :inferred_environment
        )
      )
    end

    it_behaves_like 'can be disabled', :open_base, [:test_name => :test_name]

    context 'when api_key present' do
      before do
        allow(subject).to receive(:api_key).and_return :value
      end

      it 'validates presence of app_name' do
        expect { subject.open_base(:test_name => :test_name) }.to raise_error(Applitools::EyesIllegalArgument)
        expect(subject).to receive(:viewport_size=).at_least(:once)
        subject.app_name = :test
        subject.open_base(:test_name => :test)
        expect(subject.send(:test_name)).to eq :test
      end

      it 'validates presence of test_name' do
        expect(subject).to receive(:viewport_size=).at_least(:once)
        expect { subject.open_base(:app_name => :app_name) }.to raise_error(Applitools::EyesIllegalArgument)
        subject.open_base(:app_name => :app_name, :test_name => :test)
      end

      it 'set open? to true' do
        expect(subject).to receive(:viewport_size=).at_least(:once)
        subject.send(:open=, false)
        subject.open_base :app_name => :a, :test_name => :b, :viewport_size => :c, :session_type => :d
        expect(subject.open?).to eq true
      end

      it 'aborts the test if already running' do
        subject.send(:open=, true)
        expect(subject).to receive :abort_if_not_closed
        expect { subject.open_base(:app_name => :app, :test_name => :test) }.to raise_error(Applitools::EyesError,
          'A test is already running')
      end

      it 'yields a block' do
        expect { |b| subject.open_base(:app_name => :app, :test_name => :test, &b) }.to yield_control
      end
    end

    it 'throws exception without API key' do
      subject.api_key = nil
      expect { subject.open_base(:app_name => :test, :test_name => :test) }.to raise_error(Applitools::EyesError,
        'API key is missing! Please set it using api_key=')
    end
  end

  it 'Implements start_session()' do
    expect(subject.private_methods).to include :start_session
  end

  context 'start_session()' do
  end

  context 'close()' do
    it_behaves_like 'can be disabled', :close, [false]

    let(:success_old_results) do
      Applitools::TestResults.new(
        'steps' => 5,
        'matches' => 5,
        'mismatches' => 0,
        'missing' => 0,
        'isNew' => false,
        'isDifferent' => false,
        'status' => 'Passed'
      )
    end

    let(:failed_old_results) do
      Applitools::TestResults.new(
        'steps' => 5,
        'matches' => 1,
        'mismatches' => 2,
        'missing' => 2,
        'isNew' => false,
        'isDifferent' => true,
        'status' => 'Unresolved'
      )
    end

    let(:failed_test_results) do
      Applitools::TestResults.new(
        'steps' => 5,
        'matches' => 1,
        'mismatches' => 2,
        'missing' => 2,
        'isNew' => false,
        'isDifferent' => true,
        'status' => 'Failed'
      )
    end

    let(:new_results) do
      Applitools::TestResults.new('isNew' => true, 'isDifferent' => false, 'status' => 'Unresolved').tap do |r|
        r.is_new = true
        r.url = 'http://see.results.url'
      end
    end

    let(:new_saved_results) do
      Applitools::TestResults.new('isNew' => true, 'isDifferent' => false, 'status' => 'Passed').tap do |r|
        r.is_new = true
        r.url = 'http://see.results.url'
      end
    end

    let(:r_session) { Applitools::Session.new :session_id, :session_url, false }
    let(:r_session_new) { Applitools::Session.new :session_id, :session_url, true }

    before do
      subject.instance_variable_set :@running_session, r_session
      subject.instance_variable_set :@current_app_name, :stub
      subject.instance_variable_set :@open, true
    end

    it 'drops running session' do
      obj = Object.new
      expect(subject).to receive(:server_connector).and_return obj
      expect(obj).to receive(:stop_session).and_return(success_old_results)
      subject.close(false)
      expect(subject.instance_variable_get(:@running_session)).to be_nil
    end

    it 'drops current_app_name' do
      obj = Object.new
      expect(subject).to receive(:server_connector).and_return obj
      expect(obj).to receive(:stop_session).and_return(success_old_results)
      subject.close(false)
      expect(subject.instance_variable_get(:@current_app_name)).to be_nil
    end

    it 'clears user inputs' do
      obj = Object.new
      expect(subject).to receive(:server_connector).and_return obj
      expect(obj).to receive(:stop_session).and_return(success_old_results)
      expect(subject).to receive :clear_user_inputs
      subject.close(true)
    end

    it 'trows an exception while is not open' do
      subject.instance_variable_set :@open, false
      expect { subject.close(false) }.to raise_error Applitools::EyesError
    end

    it 'returns empty result if no session started' do
      subject.instance_variable_set :@running_session, nil
      close_result = subject.close(true)
      expect(close_result).to be_a Applitools::TestResults
      expect(close_result).to eq Applitools::TestResults.new
    end

    it 'calls Applitools::Connectivity::ServerConnector.stop_session' do
      obj = Object.new
      expect(subject).to receive(:server_connector).and_return obj
      expect(obj).to receive(:stop_session).and_return(success_old_results)
      subject.close(true)
    end

    it 'sets new flag for results' do
      obj = Object.new
      expect(subject).to receive(:server_connector).and_return obj
      expect(obj).to receive(:stop_session).and_return(success_old_results)
      result = subject.close(false)
      expect(result.new?).to eq false
    end

    it 'sets server_url for results' do
      obj = Object.new
      expect(subject).to receive(:server_connector).and_return obj
      expect(obj).to receive(:stop_session).and_return(success_old_results)
      result = subject.close(false)
      expect(result.url).to eq :session_url
    end

    context 'throws an exception for failed test if called like close(true) (save_new_tests = false)' do
      before do
        expect(subject).to receive(:session_start_info).and_return(
          Applitools::SessionStartInfo.new(
            :agent_id => :a,
            :app_id_or_name => :b,
            :ver_id => :c,
            :scenario_id_or_name => :d,
            :batch_info => :e,
            :env_name => :f,
            :environment => :g
          )
        ).at_least 1
        allow(subject).to receive(:save_new_tests).and_return(false)
      end

      it 'generally failed test' do
        expect(subject).to receive(:open?).and_return(true).at_least 1
        obj = Object.new
        expect(subject).to receive(:server_connector).and_return obj
        expect(obj).to receive(:stop_session).and_return(failed_test_results)
        expect { subject.close(true) }.to raise_error Applitools::TestFailedError
      end

      it 'failed test close(true)' do
        expect(subject).to receive(:open?).and_return(true).at_least 1
        obj = Object.new
        expect(subject).to receive(:server_connector).and_return obj
        expect(obj).to receive(:stop_session).and_return(failed_old_results)
        expect { subject.close(true) }.to raise_error Applitools::DiffsFoundError
      end

      it 'new test close(true)' do
        expect(subject).to receive(:open?).and_return(true).at_least 1
        expect(subject).to receive(:running_session).and_return(r_session_new).at_least 1
        obj = Object.new
        expect(subject).to receive(:server_connector).and_return obj
        expect(obj).to receive(:stop_session).and_return(new_results)
        expect { subject.close(true) }.to raise_error Applitools::NewTestError
      end
    end

    context 'throws an exception for failed test if called like close(true) (save_new_tests = true)' do
      before do
        allow(subject).to receive(:session_start_info).and_return(
          Applitools::SessionStartInfo.new(
            :agent_id => :a,
            :app_id_or_name => :b,
            :ver_id => :c,
            :scenario_id_or_name => :d,
            :batch_info => :e,
            :env_name => :f,
            :environment => :g
          )
        ).at_least 1
        allow(subject).to receive(:save_new_tests).and_return(true)
      end

      it 'failed test close(true)' do
        expect(subject).to receive(:open?).and_return(true).at_least 1
        obj = Object.new
        expect(subject).to receive(:server_connector).and_return obj
        expect(obj).to receive(:stop_session).and_return(failed_old_results)
        expect { subject.close(true) }.to raise_error Applitools::DiffsFoundError
      end

      it 'new test close(true)' do
        expect(subject).to receive(:open?).and_return(true).at_least 1
        expect(subject).to receive(:running_session).and_return(r_session_new).at_least 1
        obj = Object.new
        expect(subject).to receive(:server_connector).and_return obj
        expect(obj).to receive(:stop_session).and_return(new_saved_results)
        expect { subject.close(true) }.to_not raise_error
      end
    end

    context 'don\'t throw exception when called like close(false)' do
      before do
        expect(subject).to receive(:session_start_info).and_return(
          Applitools::SessionStartInfo.new(
            :agent_id => :a,
            :app_id_or_name => :b,
            :ver_id => :c,
            :scenario_id_or_name => :d,
            :batch_info => :e,
            :env_name => :f,
            :environment => :g
          )
        ).at_least 1
      end

      it 'failed test close(false)' do
        expect(subject).to receive(:open?).and_return(true).at_least 1
        obj = Object.new
        expect(subject).to receive(:server_connector).and_return obj
        expect(obj).to receive(:stop_session).and_return(failed_old_results)
        subject.close(false)
      end
      it 'new test close (false)' do
        expect(subject).to receive(:open?).and_return(true).at_least 1
        expect(subject).to receive(:running_session).and_return(r_session_new).at_least 1

        obj = Object.new
        expect(subject).to receive(:server_connector).and_return obj

        expect(obj).to receive(:stop_session).and_return(new_results)
        subject.close(false)
      end
    end
  end

  context 'start session' do
    it 'a private method' do
      expect { subject.start_session }.to raise_error NoMethodError
    end
    it 'calls ServerConnector.start_session' do
      obj = Object.new
      expect(subject).to receive(:server_connector).and_return obj

      expect(obj).to receive(:start_session).and_return(
        Applitools::Session.new(:session_id, :session_url, true)
      )

      expect(subject).to receive(:viewport_size).and_return nil
      expect(subject).to receive(:get_viewport_size).and_return Applitools::RectangleSize.new(1024, 768)
      expect(subject).to receive(:inferred_environment).and_return nil
      expect(subject).to receive(:base_agent_id).and_return nil
      subject.send :start_session
    end
  end

  context 'match_window_base' do
    let(:match_data) { Applitools::MatchWindowData.new }
    let(:region_provider) do
      Applitools::RegionProvider.new(
        Applitools::Region::EMPTY,
        Applitools::EyesScreenshot::COORDINATE_TYPES[:screenshot_as_is]
      )
    end
    let(:fake_results) do
      Applitools::MatchResults.new.tap { |mr| mr.as_expected = true }
    end
    let(:match_task) do
      double.tap do |d|
        allow(d).to receive(:match_window).and_return(fake_results)
      end
    end

    it 'checks disabled? flag and logs \'Ignored\'' do
      expect(subject).to receive(:disabled?).and_return(true).at_least(1)
      expect(subject.logger).to receive(:info).with('check_window_base Ignored').at_least(1)
      subject.send(:check_window_base, nil, nil, nil)
    end

    it 'passes user inputs to match_window_data' do
      allow(Applitools::MatchWindowTask).to receive(:new).and_return(match_task)

      expect(subject).to receive :user_inputs
      expect(match_data).to receive(:user_inputs=)

      allow(subject).to receive(:open?).and_return true
      allow(subject).to receive(:get_viewport_size).and_return(Applitools::Region::EMPTY)
      allow(subject).to receive(:base_agent_id).and_return ''
      allow(subject).to receive(:capture_screenshot)
      allow(subject).to receive(:title)
      subject.check_window_base(region_provider, 0, match_data)
    end
  end

  context ':set_default_match_settins' do
    it 'sets options[:match_level]' do
      subject.set_default_match_settings(:strict)
      expect(subject.match_level).to eq Applitools::MATCH_LEVEL[:strict]
      expect { subject.set_default_match_settings('Strict') }.to raise_error Applitools::EyesError
    end
    it 'raises an exception on wrong value' do
      expect { subject.set_default_match_settings('unknown') }.to raise_error Applitools::EyesError
      expect { subject.set_default_match_settings(:none) }.to_not raise_error
    end
    it 'accepts a hash of exact values' do
      aggregate_failures do
        expect { subject.set_default_match_settings(:exact, min_diff_height: 0) }.to_not raise_error
        expect { subject.set_default_match_settings(:exact) }.to_not raise_error
      end
    end
    it 'processes exact values only if match_level == exact' do
      expect { subject.set_default_match_settings(:strict, 'MinDiffIntensity' => 0) }.to(
        raise_error Applitools::EyesError
      )
    end
    it 'raises an exception if passed hash contains extra keys' do
      expect { subject.set_default_match_settings(:exact, 'unknown_key' => 'a_value') }.to(
        raise_error Applitools::EyesError
      )
    end
    it 'accepts underscored keys as well as original' do
      expect { subject.set_default_match_settings(:exact, 'MinDiffIntensity' => 0, :min_diff_height => 0) }.to_not(
        raise_error
      )
    end
    it 'updates exact if exact values have been passed' do
      subject.exact = {}
      expect { subject.set_default_match_settings(:exact, 'MinDiffIntensity' => 0) }.to change { subject.exact }
    end
    it 'uses default exact values if nothing is passed' do
      subject.set_default_match_settings(:exact)
      aggregate_failures do
        expect(subject.exact).to be_a Hash
        expect(subject.exact.keys).to(
          contain_exactly('MinDiffIntensity', 'MinDiffWidth', 'MinDiffHeight', 'MatchThreshold')
        )
        expect(subject.exact.values).to contain_exactly(0, 0, 0, 0)
      end
    end
  end
end
