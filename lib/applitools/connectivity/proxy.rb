module Applitools::Connectivity
  Proxy = Struct.new(:uri, :user, :password) do
    def to_hash
      result = {}
      result[:uri] = uri.is_a?(URI) ? uri : URI(uri)
      result[:user] = user unless user.nil?
      result[:password] = password unless password.nil?
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
