# frozen_string_literal: true

require 'oj'
module TestUtils
  extend self
  def get_session_results(api_key, results)
    session_results(session_results_url(results, api_key))
  end

  def session_results(url)
    Oj.load(Net::HTTP.get(url))
  end

  def session_results_url(eyes_test_result, api_key)
    url = URI.parse(eyes_test_result.api_session_url)
    url.query = session_query_params(eyes_test_result, api_key)
    url
  end

  def session_query_params(eyes_test_result, api_key)
    URI.encode_www_form('AccessToken' => eyes_test_result.secret_token, 'apiKey' => api_key, 'format' => 'json')
  end

  def get_step_dom(eyes, actual_app_output)
    Applitools::ArgumentGuard.not_nil(eyes, 'eyes')
    Applitools::ArgumentGuard.not_nil(actual_app_output, 'actual_app_output')

    uri_builder = URI.parse(eyes.server_url)
    uri_builder.path = "/api/images/dom/#{actual_app_output['image']['domId']}"
    uri_builder.query = URI.encode_www_form('apiKey' => eyes.api_key)
    Oj.load(Net::HTTP.get(uri_builder))
  end
end
