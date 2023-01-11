module Applitools::Connectivity
  class UserAgentMiddleware
    attr_accessor :app, :get_user_id_proc, :server_url_proc
    def initialize(app, params)
      self.app = app
      self.get_user_id_proc = params[:get_user_agent]
      self.server_url_proc = params[:get_server_url]
    end

    def call(env)
      # server_url = URI.parse(server_url_proc.call)
      env.request_headers['x-applitools-eyes-client'] = obtain_user_id
      @app.call(env)
    end

    private

    def obtain_user_id
      return get_user_id_proc.call if get_user_id_proc.is_a?(Proc)
      Applitools::EyesLogger.error('The user ID was not set!')
      "eyes.sdk.ruby/#{Applitools::VERSION}"
    end
  end
end