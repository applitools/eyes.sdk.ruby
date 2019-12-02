# frozen_string_literal: true
require 'thread'
module Applitools
  module Selenium
    class ResourceCache
      class ResourceMissing < ::Applitools::EyesError; end
      attr_accessor :cache_map, :semaphore

      def initialize
        self.cache_map = {}
        self.semaphore = Mutex.new
      end

      def contains?(url)
        semaphore.synchronize do
          check_key(url)
        end
      end

      def [](key)
        current_value = semaphore.synchronize do
          cache_map[key]
        end
        raise ResourceMissing, key if current_value.nil?
        return current_value unless current_value.is_a? Applitools::Future
        update_cache_map(key, current_value.get)
      end

      def []=(key, value)
        Applitools::ArgumentGuard.is_a?(key, 'key', URI)
        Applitools::ArgumentGuard.one_of?(value, 'value', [Applitools::Future, Applitools::Selenium::VGResource])
        update_cache_map(key, value)
      end

      def fetch_and_store(key, &_block)
        semaphore.synchronize do
          return cache_map[key] if check_key(key)
          return unless block_given?
          cache_map[key] = Applitools::Future.new(semaphore) do |semaphore|
            yield(semaphore, key)
          end
          return true if cache_map[key].is_a? Applitools::Future
          false
        end
      end

      private

      def check_key(url)
        cache_map.keys.include?(url) && !cache_map[url].nil?
      end

      def update_cache_map(key, value)
        semaphore.synchronize do
          cache_map[key] = value
        end
      end
    end
  end
end
