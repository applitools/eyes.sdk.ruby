# frozen_string_literal: true
require_relative '../../lib/test_utils/obtain_actual_app_output'
require 'driver_build'
RSpec.configure do |config|
  config.formatter = :documentation

  include Applitools::TestUtils::ObtainActualAppOutput
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  def get_test_info(results)
    actual_app_output(@eyes.api_key, results)
  end

  def get_dom(results, dom_id)
    url = URI.parse(results.url)
    new_query_ar = URI.decode_www_form(url.query || '') << ['apiKey', ENV['APPLITOOLS_API_KEY_READ']]
    url.path = "/api/images/dom/#{dom_id}/"
    url.query = URI.encode_www_form(new_query_ar)
    asd = Net::HTTP.get(url)
    Oj.load(asd)
  end

  def get_nodes_by_attribute(node, attr)
    result = []
    if node.key?('attributes') && node['attributes'].key?(attr)
      result.push(node)
    end
    if node.key?('childNodes')
      node['childNodes'].each { |child| result.push(get_nodes_by_attribute(child, attr)) }
    end
    result.flatten
  end

end
