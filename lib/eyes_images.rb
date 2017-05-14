require 'eyes_core'

module Applitools::Images
  # @!visibility private
  class << self
    # @!visibility private
    def require_dir(dir)
      Dir[File.join(File.dirname(File.expand_path(__FILE__)), 'applitools', dir, '*.rb')].sort.each do |f|
        require f
      end
    end
  end
end

Applitools::Images.require_dir 'images'
