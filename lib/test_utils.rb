require_relative 'require_utils'
require 'eyes_core'

module Applitools
  module TestUtils
    TEST_REPORT_SERVER_URL = 'http://applitools-quality-server.herokuapp.com'
    SDK_TEST_REPORT_ENDPOINT = '/result'
    def self.load_dir
      File.dirname(File.expand_path(__FILE__))
    end

    def self.require_dir(dir)
      Dir[File.join(load_dir, 'test_utils', dir, '*.rb')].sort.each do |f|
        require f
      end
    end

    self.require_dir('')
  end
end

RSpec.configure do |config|
  config.before(:all, report_me: true) do |example_group|
    begin
      @test_results_to_be_reported = Applitools::TestUtils::TestResults.new(
        sdk: 'ruby',
        group: example_group.test_reporting_group,
        id: ENV['TRAVIS_COMMIT'] || (example_group.respond_to?(:test_reporting_id) && example_group.test_reporting_id),
        sandbox: ENV['TEST_REPORT_SANDBOX'] != 'False'
      )
      @report_connection = Faraday.new(
        Applitools::TestUtils::TEST_REPORT_SERVER_URL,
        headers: {'Content-Type' => 'application/json'}
      )
    rescue NoMethodError => e
      puts e.message
      puts "Please, define the appropriate method for the example_group #{example_group}"
    end
  end

  config.after(:all, report_me: true) do |_example_group|
    begin
      response = @report_connection.post(Applitools::TestUtils::SDK_TEST_REPORT_ENDPOINT) do |req|
        req.body = @test_results_to_be_reported.json
        puts req.body #if ENV['APPLITOOLS_DEBUG_TEST_REPORTING']
      end
      puts "Reported test results with status #{response.status}"
    rescue StandardError => e
      puts 'Error while reporting test results'
      puts e.message
    end
  end

  config.around report_me: true do |example|
    example.run
    begin
      test_result = Applitools::TestUtils::TestResult.new(
          browser: 'chrome',
          stitching: example.metadata[:scroll] ? 'scroll' : 'css',
          mode: example.metadata[:visual_grid] ? 'VisualGrid' : nil,
          test_name: example.description,
          passed: example.executed? && example.exception.nil?
      )
      @test_results_to_be_reported.results << test_result
    rescue StandardError => e
      puts 'Error while collecting test results to report'
      puts e.message
    end
  end
end