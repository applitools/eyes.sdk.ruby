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
          @nodes_by_type = {}
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
          result = []
          node[:tokens].select { |t| t[:node] == :url }.uniq.each do |nd|
            result << nd[:value] if nd && !nd.empty?
          end
          node[:tokens].select { |t| t[:node] == :function && t[:value] == 'url' }.uniq.each do |nd|
            url_index = node[:tokens].index(nd)
            url_string_node = url_index && node[:tokens][url_index + 1]
            result << (
              url_string_node && url_string_node[:node] == :string &&
                  !url_string_node[:value].empty? && url_string_node[:value]
            )
          end
          result.compact
        end

        def fetch_urls(nodes)
          nodes.map { |n| url(n) }.flatten.compact
        end

        def import_rules
          # css_nodes.select { |n| n[:node] == :at_rule && n[:name] == 'import' }
          nodes_by_type[:import_rules]
        end

        def font_face_rules
          # css_nodes.select { |n| n[:node] == :at_rule && n[:name] == 'font-face' }
          nodes_by_type[:font_face_rules]
        end

        def images_rules
          # css_nodes.select { |n| n[:node] == :style_rule }.map { |n| n[:children] }
          #          .flatten
          #          .select { |n| n[:node] == :property && (n[:name] == 'background' || n[:name] == 'background-image') }
          nodes_by_type[:images_rules]
        end

        def css_nodes
          @css_nodes ||= parse_nodes
        end

        def nodes_by_type
          return @nodes_by_type unless @nodes_by_type.empty?
          @nodes_by_type[:import_rules] ||= []
          @nodes_by_type[:font_face_rules] ||= []
          @nodes_by_type[:images_rules] ||= []
          css_nodes.each do |n|
            @nodes_by_type[:import_rules] << n if n[:node] == :at_rule && n[:name] == 'import'
            @nodes_by_type[:font_face_rules] << n if n[:node] == :at_rule && n[:name] == 'font-face'
            @nodes_by_type[:images_rules] << n if n[:node] == :style_rule
          end

          unless @nodes_by_type[:images_rules].nil?
            @nodes_by_type[:images_rules].map! { |n| n[:children] }.flatten!
            @nodes_by_type[:images_rules] = @nodes_by_type[:images_rules].select do |n|
              n[:node] == :property && (n[:name] == 'background' || n[:name] == 'background-image')
            end
          end
          @nodes_by_type
        end

        def parse_nodes
          Crass.parse css
        end
      end
    end
  end
end
