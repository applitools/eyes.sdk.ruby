# frozen_string_literal: true

require 'eyes_core'

module Applitools
  module Images
    extend Applitools::RequireUtils

    def self.load_dir
      File.dirname(File.expand_path(__FILE__))
    end
  end
end

Applitools::Images.require_dir 'images'
