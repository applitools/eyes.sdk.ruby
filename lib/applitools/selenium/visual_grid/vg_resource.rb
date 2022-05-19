# frozen_string_literal: true

require 'base64'
require 'digest'
# require 'nokogiri'

module Applitools
  module Selenium
    class VGResource
      include Applitools::Jsonable
      json_fields :contentType, :hash, :hashFormat, :errorStatusCode
      attr_accessor :url, :content, :handle_discovered_resources_block
      alias content_type contentType
      alias content_type= contentType=

      class << self
        def parse_blob_from_script(blob, options = {})
          return new(
            blob['url'],
            "application/X-error-response-#{blob['errorStatusCode']}",
            blob['value'] || ''
          ).tap {|r| r.error_status_code = blob['errorStatusCode']} if blob['errorStatusCode']
          content = Base64.decode64(blob['value'])
          new(blob['url'], blob['type'], content, options)
        end

        def parse_response(url, response, options = {})
          return new(url, 'application/empty-response', '') unless response.status == 200
          new(url, response.headers['Content-Type'], response.body, options)
        end
      end

      def initialize(url, content_type, content, options = {})
        self.handle_discovered_resources_block = options[:on_resources_fetched] if
            options[:on_resources_fetched].is_a? Proc
        self.url = URI(url)
        self.content_type = content_type
        self.content = content
        self.hash = Digest::SHA256.hexdigest(content)
        self.hashFormat = 'sha256'
        lookup_for_resources
      end

      def on_resources_fetched(block)
        self.handle_discovered_resources_block = block
      end

      def lookup_for_resources
        lookup_for_css_resources
        lookup_for_svg_resources
      end

      def lookup_for_css_resources
        return unless %r{^text/css}i =~ content_type && handle_discovered_resources_block
        parser = Applitools::Selenium::CssParser::FindEmbeddedResources.new(content)
        handle_discovered_resources_block.call(parser.imported_css + parser.fonts + parser.images, url)
      end

      def lookup_for_svg_resources
        return unless %r{^image/svg\+xml} =~ content_type && handle_discovered_resources_block
        attrs = []
        # attrs = Nokogiri::XML(content)
        #                 .xpath("//@*[namespace-uri(.) = 'http://www.w3.org/1999/xlink'] | //@href")
        #                 .select { |a| a.name == 'href' }
        #                 .map(&:value)
        #                 .select { |a| /^(?!#).*/.match(a) }
        handle_discovered_resources_block.call(attrs, url)
      end

      def stringify
        url.to_s + content_type.to_s + hash
      end

      private :lookup_for_svg_resources, :lookup_for_css_resources
    end
  end
end
