# frozen_string_literal: true

module Applitools
  module Selenium
    class BrowsersInfo < Set
      def add(obj)
        return super if obj.is_a? Applitools::Selenium::IRenderBrowserInfo
        raise(
          Applitools::EyesIllegalArgument,
          'It is expected the value to be an Applitools::Selenium::RenderBrowserInfo instance,' \
          " but got #{obj.class} instead"
        )
      end

      def each(viewport_size = nil)
        return super() unless empty?
        return unless viewport_size
        default = Applitools::Selenium::DesktopBrowserInfo.new.tap do |bi|
          bi.viewport_size = viewport_size
          bi.browser_type = BrowserTypes::CHROME
        end
        yield(default)
      end

      def to_hash
        return nil if empty?
        map(&:to_hash)
        # require 'pry'
        # binding.pry
      end

    end
  end
end
