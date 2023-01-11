# frozen_string_literal: true

module Applitools::Connectivity
  Proxy = Struct.new(:uri, :user, :password, :is_http_only) do
    # export type Proxy = {
    #   url: string
    #   username?: string
    #   password?: string
    #   isHttpOnly?: boolean
    # }
    def to_hash
      result = {}
      result[:url] = uri.is_a?(String) ? uri : uri.to_s
      result[:username] = user unless user.nil?
      result[:password] = password unless password.nil?
      result[:isHttpOnly] = !!is_http_only unless is_http_only.nil?
      result
    end

    def uri=(value)
      if value.is_a? URI
        super
      else
        super URI.parse(value)
      end
    end
  end
end
# U-Notes : add is_http_only/isHttpOnly flag
