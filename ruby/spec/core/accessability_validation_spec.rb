OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
RSpec.describe 'AccessibilityValidation' do
  context 'accessibility_settings' do
    let(:valid) do
      Applitools::AccessibilitySettings.new(
        Applitools::AccessibilityLevel::AA,
        Applitools::AccessibilityGuidelinesVersion::WCAG_2_0
      )
    end

    it 'returns hash' do
      expect(valid).to respond_to :to_h
      expect(valid.to_h[:level]).to eq 'AA'
      expect(valid.to_h[:version]).to eq 'WCAG_2_0'
    end

    it 'responds_to :json_data' do
      expect(valid).to respond_to(:json_data)
    end

    it 'rejects wrong values' do
      expect { Applitools::AccessibilitySettings.new('BBB', 'WCAG_2_0') }.to(
        raise_error(
          Applitools::EyesIllegalArgument
        )
      )
      expect { Applitools::AccessibilitySettings.new('AAA', 'BLAH') }.to(
          raise_error(Applitools::EyesIllegalArgument)
      )
    end

    it 'accepts allowed values' do
      expect { Applitools::AccessibilitySettings.new('AA', 'WCAG_2_0')}.to_not raise_error
      expect { Applitools::AccessibilitySettings.new('AAA', 'WCAG_2_0')}.to_not raise_error
      expect { Applitools::AccessibilitySettings.new('AA', 'WCAG_2_1')}.to_not raise_error
      expect { Applitools::AccessibilitySettings.new('AAA', 'WCAG_2_1')}.to_not raise_error
    end
  end
  context 'ImageMatchSettings' do
    subject { Applitools::ImageMatchSettings.new }
    let(:as) { Applitools::AccessibilitySettings.new(Applitools::AccessibilityLevel::AA, Applitools::AccessibilityGuidelinesVersion::WCAG_2_0) }
    it 'accepts nil value for :accessibility_validation=' do
      expect { subject.accessibility_validation = nil }.to_not raise_error
    end
    it 'accepts Applitools::AccessibilitySettings for :accessibility_validation=' do
      expect { subject.accessibility_validation = as }.to_not raise_error
    end
    it 'rejects wrong type for :accessibility_validation=' do
      expect { subject.accessibility_validation = Struct.new(:accessibility_level) }.to raise_error Applitools::EyesIllegalArgument
    end
    context 'json' do
      it 'has :accessibilitySettings property' do
        subject.accessibility_validation = as
        expect(subject.json_data.keys).to include(:accessibilitySettings)
      end
      it ':accessibilitySettings value' do
        subject.accessibility_validation = as
        expect(subject.json_data[:accessibilitySettings]).to be_a Hash
        expect(subject.json_data[:accessibilitySettings][:level]).to eq(as.level)
        expect(subject.json_data[:accessibilitySettings][:version]).to eq(as.version)
      end
    end
  end
  context 'AccessibilitySettings' do
    shared_examples 'has_accessibility_settings' do
      it ('accessibility related methods') do
        expect(config).to respond_to :accessibility_validation
        expect(config).to respond_to :accessibility_validation=
        expect(config.default_match_settings).to respond_to(:accessibility_validation)
        expect(config.default_match_settings).to respond_to(:accessibility_validation=)
        expect(config.default_match_settings.accessibility_validation).to be nil
      end
      it 'sets :accessibility_settings' do
        expect(config.default_match_settings.accessibility_settings).to be nil
        ac = Applitools::AccessibilitySettings.new(Applitools::AccessibilityLevel::AAA, Applitools::AccessibilityGuidelinesVersion::WCAG_2_0)
        config.accessibility_validation = ac
        expect(config.default_match_settings.accessibility_settings).to be_a(Applitools::AccessibilitySettings)
        expect(config.default_match_settings.accessibility_settings.level).to eq ac.level
        expect(config.default_match_settings.accessibility_settings.version).to eq ac.version
      end
    end
    context 'Core' do
      let(:config) { Applitools::EyesBaseConfiguration.new }
      it_behaves_like 'has_accessibility_settings'
    end
    context 'Selenium' do
      let(:config) { Applitools::Selenium::Configuration.new }
      it_behaves_like 'has_accessibility_settings'
    end
  end
  context 'integration' do
    let(:driver) { Selenium::WebDriver.for :chrome, options: Selenium::WebDriver::Chrome::Options.new(args: [:headless]) }
    let(:eyes) do
      eyes = Applitools::Selenium::Eyes.new(runner: runner)
      eyes.configure do |config|
        config.server_url = 'https://eyesapi.applitools.com'
        config.set_proxy('http://localhost:8000') unless ENV['TRAVIS']
        config.accessibility_validation = Applitools::AccessibilitySettings.new(Applitools::AccessibilityLevel::AA, Applitools::AccessibilityGuidelinesVersion::WCAG_2_0)
      end
      eyes
    end
    shared_examples 'accessibility settings' do
      it 'test', skip: true do
        begin
          driver.get('https://applitools.github.io/demo/TestPages/FramesTestPage/')
          eyes.open(
              app_name: 'Applitools Eyes SDK',
              test_name: 'TestAccessibility_Sanity' + suffix,
              viewport_size: { width: 700, height: 460 },
              driver: driver
          )
          eyes.check(
              'Sanity',
              Applitools::Selenium::Target.window.accessibility(
                  :class_name,
                  'ignore',
                  type: Applitools::AccessibilityRegionType::LARGE_TEXT
              )
          )
          eyes.close_async
          eyes.configure do |config|
            config.accessibility_validation = nil
            config.test_name = 'TestAccessibility_No_Accessibility' + suffix
          end
          eyes.open(
              app_name: 'Applitools Eyes SDK',
              test_name: 'TestAccessibility_No_Accessibility' + suffix,
              viewport_size: {width: 1200, height: 600},
              driver: driver
          )
          eyes.check_window('No accessibility')
          eyes.close_async
        ensure
          driver.quit
          eyes.abort_async
          all_test_results = runner.get_all_test_results(false)
          expect(all_test_results.length).to eq 2
          resultSanity = all_test_results[0]
          resultNoAccessibility = all_test_results[1]

          if (resultNoAccessibility.name =~ /^TestAccessibility_Sanity/)
            temp = resultNoAccessibility
            resultNoAccessibility = resultSanity
            resultSanity = temp
          end

          accessibility_status = resultSanity.session_accessibility_status
          expect(accessibility_status.level).to eq('AA')
          expect(accessibility_status.version).to eq('WCAG_2_0')
          expect(resultNoAccessibility.session_accessibility_status).to be nil

          session_results = session_results(eyes.api_key, resultSanity)
          default_match_settings = session_results['startInfo']['defaultMatchSettings']
          expect(default_match_settings['accessibilitySettings']).to eq({'level' => 'AA', 'version' => 'WCAG_2_0'})

          actual_accessibility_settings = session_results['actualAppOutput'][0]['imageMatchSettings']['accessibility']
          expect(actual_accessibility_settings).to include({'type'=>'LargeText', 'isDisabled'=>false, 'left'=>122, 'top'=>928, 'width'=>456, 'height'=>306})
          expect(actual_accessibility_settings).to include({'type'=>'LargeText', 'isDisabled'=>false, 'left'=>8, 'top'=>1270, 'width'=>675, 'height'=>206})
          expect(actual_accessibility_settings).to include({'type'=>'LargeText', 'isDisabled'=>false, 'left'=>10, 'top'=>284, 'width'=>800, 'height'=>500})
        end
      end

      def session_results(api_key, test_result)
        Oj.load(Net::HTTP.get(session_results_url(api_key, test_result)))
      end

      def session_query_params(api_key, test_results)
        URI.encode_www_form('AccessToken' => test_results.secret_token, 'apiKey' => api_key, 'format' => 'json')
      end

      def session_results_url(api_key, test_result)
        url = URI.parse(test_result.api_session_url)
        url.query = session_query_params(api_key, test_result)
        url
      end

    end
    context 'classic selenium' do
      let(:runner) { Applitools::ClassicRunner.new }
      let(:suffix) { '' }
      it_should_behave_like 'accessibility settings'
    end

    context 'visual grid' do
      let(:runner) { Applitools::Selenium::VisualGridRunner.new(5) }
      let(:suffix) { '_VG' }
      it_should_behave_like 'accessibility settings'
    end
  end
end