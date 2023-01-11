module Applitools
  module TestUtils
    module ObtainActualAppOutput
      def app_output(api_key, eyes_test_result = nil)
        app_output_getter = ActualAppOutputGetter.new { actual_app_output(api_key, eyes_test_result || @eyes_test_result) }
        @actual_app_output_check.push app_output_getter rescue nil
        app_output_getter
      end

      def actual_app_output(api_key, eyes_test_result)
        session_results(eyes_test_result.api_session_url, eyes_test_result.secret_token, api_key)
      end

      def session_results(api_session_url, secret_token, api_key)
        Oj.load(Net::HTTP.get(session_results_url(api_session_url, secret_token, api_key)))
      end

      def session_query_params(secret_token, api_key)
        URI.encode_www_form('AccessToken' => secret_token, 'apiKey' => api_key, 'format' => 'json')
      end

      def session_results_url(api_session_url, secret_token, api_key)
        url = URI.parse(api_session_url)
        url.query = session_query_params(secret_token, api_key)
        url
      end
    end
  end
end