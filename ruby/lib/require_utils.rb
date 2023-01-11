# frozen_string_literal: true

module Applitools
  module RequireUtils
    # @!visibility private
    def require_dir(dir)
      Dir[File.join(load_dir, 'applitools', dir, '*.rb')].sort.each do |f|
        require f
      end
    end
  end
end
