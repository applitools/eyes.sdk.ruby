# frozen_string_literal: true

require 'base64'
require 'digest'
module Applitools
  module Selenium
    class VGResource
      include Applitools::Jsonable
      json_fields :contentType, :hash, :hashFormat
      attr_accessor :url, :content, :handle_css_block
      alias content_type contentType
      alias content_type= contentType=

      class << self
        def parse_blob_from_script(blob, options = {})
          content = Base64.decode64(blob['value'])
          new(blob['url'], blob['type'], content, options)
        end

        def parse_response(url, response, options = {})
          return new(url, 'application/empty-response', '') unless response.status == 200
          new(url, response.headers['Content-Type'], response.body, options)
        end
      end

      def initialize(url, content_type, content, options = {})
        self.handle_css_block = options[:on_css_fetched] if options[:on_css_fetched].is_a? Proc
        self.url = URI(url)
        self.content_type = content_type
        self.content = content
        self.hash = Digest::SHA256.hexdigest(content)
        self.hashFormat = 'sha256'
        lookup_for_resources
      end

      def on_css_fetched(block)
        self.handle_css_block = block
      end

      def lookup_for_resources
        return unless %r{^text/css}i =~ content_type && handle_css_block
        parser = Applitools::Selenium::CssParser::FindEmbeddedResources.new(content)
        handle_css_block.call(parser.imported_css + parser.fonts + parser.images, url)
      end

      def stringify
        url.to_s + content_type.to_s + hash
      end
    end
  end
end
