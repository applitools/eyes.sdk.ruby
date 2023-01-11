# frozen_string_literal: true

module Applitools
  class Session
    attr_reader :id, :url, :new_session, :session_data
    attr_accessor :new_session
    private :new_session, :new_session=

    def initialize(server_response, new_session)
      @session_data = server_response
      @id = session_data['id']
      @url = session_data['url']
      @new_session = new_session
    end

    def new_session?
      unless (result = session_data['isNew']).nil?
        return @new_session unless result.is_a?(TrueClass) | result.is_a?(FalseClass)
        return result
      end
      @new_session
    end
  end
end
