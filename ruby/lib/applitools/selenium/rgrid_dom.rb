# frozen_string_literal: false
module Applitools
  module Selenium
    class RGridDom
      CONTENT_TYPE = 'x-applitools-html/cdt'.freeze
      include Applitools::Jsonable
      json_fields :hash, :hashFormat
      attr_accessor :dom_nodes, :resources, :url, :data

      def initialize(*args)
        options = Applitools::Utils.extract_options! args
        self.url = options[:url]
        self.dom_nodes = options[:dom_nodes]
        self.resources = options[:resources]
        self.hash_format = 'sha256'
        self.data = {
          'resources' => resources,
          'domNodes' => dom_nodes
        }
        self.hash = calculate_sha_256
      end

      def calculate_sha_256
        Digest::SHA256.hexdigest(content)
      end

      def content
        Oj.dump(json_value(data.sort.to_h))
      end

      def resource
        Applitools::Selenium::VGResource.new(
          url,
          CONTENT_TYPE,
          content
        )
      end
    end
  end
end
