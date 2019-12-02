# frozen_string_literal: true
require 'base64'
require 'applitools/selenium/visual_grid/vg_task'

module Applitools
  module Selenium
    class RenderTask < VGTask
      include Applitools::Jsonable
      MAX_FAILS_COUNT = 5
      MAX_ITERATIONS = 100

      class << self
        def apply_base_url(discovered_url, base_url)
          target_url = discovered_url.is_a?(URI) ? discovered_url : URI.parse(discovered_url)
          return target_url.freeze if target_url.host
          target_with_base = base_url.is_a?(URI) ? base_url.dup : URI.parse(base_url)
          target_url = target_with_base.merge target_url
          target_url.freeze
        end
      end

      attr_accessor :script, :running_tests, :resource_cache, :put_cache, :server_connector,
        :rendering_info, :request_resources, :dom_url_mod, :result, :region_selectors, :size_mode,
        :region_to_check, :script_hooks, :visual_grid_manager, :discovered_resources

      def initialize(name, script_result, visual_grid_manager, server_connector, region_selectors, size_mode,
        region, script_hooks, mod = nil)

        self.result = nil
        self.script = script_result
        self.visual_grid_manager = visual_grid_manager
        self.server_connector = server_connector
        self.resource_cache = visual_grid_manager.resource_cache
        self.put_cache = visual_grid_manager.put_cache
        self.rendering_info = visual_grid_manager.rendering_info(server_connector)
        self.region_selectors = region_selectors
        self.size_mode = size_mode
        self.region_to_check = region
        self.script_hooks = script_hooks if script_hooks.is_a?(Hash)

        self.dom_url_mod = mod
        self.running_tests = []
        @discovered_resources_lock = Mutex.new
        super(name) do
          perform
        end
      end

      def perform
        rq = prepare_data_for_rg(script_data)
        fetch_fails = 0
        loop do
          response = nil
          begin
            response = server_connector.render(rendering_info['serviceUrl'], rendering_info['accessToken'], rq)
          rescue StandardError => e
            Applitools::EyesLogger.error(e.message)
            fetch_fails += 1
            sleep 2
          end
          next unless response
          need_more_dom = false
          need_more_resources = false

          response.each_with_index do |running_render, index|
            rq[index].render_id = running_render['renderId']
            need_more_dom = running_render['needMoreDom']
            need_more_resources = running_render['renderStatus'] == 'need-more-resources'

            dom_resource = rq[index].dom.resource

            cache_key = URI(dom_resource.url)
            cache_key.query = "modifier=#{dom_url_mod}" if dom_url_mod

            if need_more_resources
              running_render['needMoreResources'].each do |resource_url|
                put_cache.fetch_and_store(URI(resource_url)) do |_s|
                  server_connector.render_put_resource(
                    rendering_info['serviceUrl'],
                    rendering_info['accessToken'],
                    request_resources[URI(resource_url)],
                    running_render
                  )
                end
              end
            end

            next unless need_more_dom
            put_cache.fetch_and_store(cache_key) do |_s|
              server_connector.render_put_resource(
                rendering_info['serviceUrl'],
                rendering_info['accessToken'],
                dom_resource,
                running_render
              )
            end
            put_cache[cache_key]
          end

          still_running = need_more_resources || need_more_dom || fetch_fails > MAX_FAILS_COUNT
          break unless still_running
        end
        statuses = poll_render_status(rq)
        if statuses.first['status'] == 'error'
          raise Applitools::EyesError, "Render failed for #{statuses.first['renderId']} with the message: " \
          "#{statuses.first['error']}"
        end
        self.result = statuses.first
        statuses
      end

      def poll_render_status(rq)
        iterations = 0
        statuses = []
        loop do
          fails_count = 0
          proc = proc do
            server_connector.render_status_by_id(
              rendering_info['serviceUrl'],
              rendering_info['accessToken'],
              Oj.dump(json_value(rq.map(&:render_id)))
            )
          end
          loop do
            begin
              statuses = proc.call
              fails_count = 0
            rescue StandardError => _e
              sleep 1
              fails_count += 1
            ensure
              iterations += 1
              sleep 0.5
            end
            break unless fails_count > 0 && fails_count < 3
          end
          finished = !statuses.map { |s| s['status'] }.uniq.include?('rendering') || iterations > MAX_ITERATIONS
          break if finished
        end
        statuses
      end

      def script_data
        # @script_data ||= Oj.load script
        @script_data ||= script
      end

      def prepare_data_for_rg(data)
        self.request_resources = Applitools::Selenium::RenderResources.new
        dom = parse_frame_dom_resources(data)

        prepare_rg_requests(running_tests, dom)
      end

      def parse_frame_dom_resources(data)
        all_blobs = data['blobs']
        resource_urls = data['resourceUrls'].map { |u| URI(u) }
        discovered_resources = []

        fetch_block = proc {}

        handle_css_block = proc do |urls_to_fetch, url|
          urls_to_fetch.each do |discovered_url|
            target_url = self.class.apply_base_url(URI.parse(discovered_url), url)
            next unless /^http/i =~ target_url.scheme
            @discovered_resources_lock.synchronize do
              discovered_resources.push target_url
            end
            resource_cache.fetch_and_store(target_url, &fetch_block)
          end
        end

        fetch_block = proc do |_s, key|
          resp_proc = proc { |u| server_connector.download_resource(u) }
          retry_count = 3
          response = nil
          loop do
            retry_count -= 1
            response = resp_proc.call(key.dup)
            break unless response.status != 200 && retry_count > 0
          end
          Applitools::Selenium::VGResource.parse_response(key.dup, response, on_css_fetched: handle_css_block)
        end

        data['frames'].each do |f|
          f['url'] = self.class.apply_base_url(f['url'], data['url'])
          request_resources[f['url']] = parse_frame_dom_resources(f).resource
        end

        blobs = all_blobs.map { |blob| Applitools::Selenium::VGResource.parse_blob_from_script(blob) }.each do |blob|
          request_resources[blob.url] = resource_cache[blob.url] = blob
        end

        blobs.each do |blob|
          blob.on_css_fetched(handle_css_block)
          blob.lookup_for_resources
        end

        resource_urls.each do |url|
          resource_cache.fetch_and_store(url, &fetch_block)
        end

        resource_urls.each do |u|
          begin
            request_resources[u] = resource_cache[u]
          rescue Applitools::Selenium::RenderResources => e
            Applitools::EyesLogger.error(e.message)
          end
        end

        discovered_resources.each do |u|
          request_resources[u] = resource_cache[u]
        end

        Applitools::Selenium::RGridDom.new(
          url: data['url'], dom_nodes: data['cdt'], resources: request_resources
        )
      end

      def prepare_rg_requests(running_tests, dom)
        requests = Applitools::Selenium::RenderRequests.new

        running_tests.each do |running_test|
          r_info = Applitools::Selenium::RenderInfo.new.tap do |r|
            r.width = running_test.browser_info.viewport_size.width
            r.height = running_test.browser_info.viewport_size.height
            r.size_mode = size_mode
            r.region = region_to_check
            r.emulation_info = running_test.browser_info.emulation_info if running_test.browser_info.emulation_info
          end

          requests << Applitools::Selenium::RenderRequest.new(
            webhook: rendering_info['resultsUrl'],
            url: script_data['url'],
            dom: dom,
            resources: request_resources,
            render_info: r_info,
            browser: { name: running_test.browser_info.browser_type, platform: running_test.browser_info.platform },
            script_hooks: script_hooks,
            selectors_to_find_regions_for: region_selectors,
            send_dom: running_test.eyes.config.send_dom.nil? ? false.to_s : running_test.eyes.config.send_dom.to_s
          )
        end
        requests
      end

      def add_running_test(running_test)
        if running_tests.include?(running_test)
          raise Applitools::EyesError, "The running test #{running_test} already exists in the render task"
        end
        running_tests << running_test
        running_tests.length - 1
      end
    end
  end
end
