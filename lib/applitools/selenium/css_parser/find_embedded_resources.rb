# frozen_string_literal: true

require 'crass'

module Applitools
  module Selenium
    module CssParser
      class FindEmbeddedResources
        class << self
        end

        class CssParseError < Applitools::EyesError; end

        attr_accessor :css

        def initialize(css)
          self.css = css
        end

        def imported_css
          fetch_urls(import_rules)
        end

        def fonts
          fetch_urls(font_face_rules)
        end

        def images
          fetch_urls(images_rules)
        end

        private

        def url(node)
          url = node[:tokens].select { |t| t[:node] == :url }.first
          return url[:value] if url && !url.empty?
          url = node[:tokens].select { |t| t[:node] == :function && t[:value] == 'url' }.first
          url_index = node[:tokens].index(url)
          url_string_node = url_index && node[:tokens][url_index + 1]
          url_string_node &&
            url_string_node[:node] == :string && !url_string_node[:value].empty? && url_string_node[:value]
        end

        def fetch_urls(nodes)
          nodes.map { |n| url(n) }.compact
        end

        def import_rules
          css_nodes.select { |n| n[:node] == :at_rule && n[:name] == 'import' }
        end

        def font_face_rules
          css_nodes.select { |n| n[:node] == :at_rule && n[:name] == 'font-face' }
        end

        def images_rules
          css_nodes.select { |n| n[:node] == :style_rule }.map { |n| n[:children] }
                   .flatten
                   .select { |n| n[:node] == :property && (n[:name] == 'background' || n[:name] == 'background-image') }
        end

        def css_nodes
          @css_nodes ||= parse_nodes
        end

        def parse_nodes
          Crass.parse css
        end
      end
    end
  end
end
