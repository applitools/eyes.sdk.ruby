# frozen_string_literal: true
require 'css_parser'

module Applitools
  module Selenium
    class ExternalCssResources
      include CssParser
      def initialize(url, _base_url = nil)
        @parser = CssParser::Parser.new(absolute_paths: true)
        @parser.load_uri!(url)
        @parser.compact!
      end

      def flatten_rules
        @flatten ||= flatten_hash(hash, 0)
      end

      def hash
        @h ||= @parser.to_h
      end

      def images
        result = []
        @parser.each_rule_set do |s|
          s.expand_background_shorthand!
          result.push(s) unless s.get_value('background-image').empty?
        end
        result
      end
    end
  end
end
