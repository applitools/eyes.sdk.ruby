module Applitools
  module Selenium
    class IRenderBrowserInfo < ::Applitools::AbstractConfiguration

      object_field :viewport_size, Applitools::RectangleSize
      enum_field :browser_type, BrowserType.enum_values
      string_field :platform
      string_field :size_mode
      string_field :baseline_env_name

      def initialize(options = {})
        super()
        self.baseline_env_name = options[:baseline_env_name] if options[:baseline_env_name]
      end

      def to_s
        return "#{viewport_size} (#{browser_type})"
      end
    end
  end
end