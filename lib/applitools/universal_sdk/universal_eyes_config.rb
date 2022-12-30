# frozen_string_literal: true

module Applitools
  class UniversalEyesConfig
    include Applitools::Jsonable

    # export type EyesBaseConfig = {
    #   logs?: LogHandler
    #   debugScreenshots?: DebugScreenshotHandler
    #   agentId?: string
    #   apiKey?: string
    #   serverUrl?: string
    #   proxy?: Proxy
    #   isDisabled?: boolean
    #   connectionTimeout?: number
    #   removeSession?: boolean
    #   remoteEvents?: {serverUrl: string; accessKey?: string; timeout?: number}
    # }
    json_fields :logs,
      :debugScreenshots,
      :agentId,
      :apiKey,
      :serverUrl,
      :proxy,
      :isDisabled,
      :connectionTimeout,
      :removeSession,
      :remoteEvents

    # export type EyesOpenConfig = {
    #   appName?: string
    #   testName?: string
    #   displayName?: string
    #   viewportSize?: Size
    #   sessionType?: SessionType
    #   properties?: CustomProperty[]
    #   batch?: Batch
    #   defaultMatchSettings?: MatchSettings<Region>
    #   hostApp?: string
    #   hostOS?: string
    #   hostAppInfo?: string
    #   hostOSInfo?: string
    #   deviceInfo?: string
    #   baselineEnvName?: string
    #   environmentName?: string
    #   branchName?: string
    #   parentBranchName?: string
    #   baselineBranchName?: string
    #   compareWithParentBranch?: boolean
    #   ignoreBaseline?: boolean
    #   saveFailedTests?: boolean
    #   saveNewTests?: boolean
    #   saveDiffs?: boolean
    #   dontCloseBatches?: boolean
    # }
    json_fields :appName,
      :testName,
      :displayName,
      :viewportSize,
      :sessionType,
      :properties,
      :batch,
      :defaultMatchSettings,
      :hostApp,
      :hostOS,
      :hostAppInfo,
      :hostOSInfo,
      :deviceInfo,
      :baselineEnvName,
      :environmentName,
      :branchName,
      :parentBranchName,
      :baselineBranchName,
      :compareWithParentBranch,
      :ignoreBaseline,
      :saveFailedTests,
      :saveNewTests,
      :saveDiffs,
      :dontCloseBatches

    # export type EyesCheckConfig = {
    #   sendDom?: boolean
    #   matchTimeout?: number
    #   forceFullPageScreenshot?: boolean
    # }
    json_fields :sendDom,
      :matchTimeout,
      :forceFullPageScreenshot

    # export type EyesClassicConfig<TElement = unknown, TSelector = unknown> = {
    #   waitBeforeScreenshots?: number
    #   stitchMode?: StitchMode
    #   hideScrollbars?: boolean
    #   hideCaret?: boolean
    #   stitchOverlap?: number
    #   scrollRootElement?: TElement | TSelector
    #   cut?: ImageCropRect | ImageCropRegion
    #   rotation?: ImageRotation
    #   scaleRatio?: number
    #   waitBeforeCapture?: number
    # }
    json_fields :waitBeforeScreenshots,
      :stitchMode,
      :hideScrollbars,
      :hideCaret,
      :stitchOverlap,
      :scrollRootElement,
      :cut,
      :rotation,
      :scaleRatio,
      :waitBeforeCapture

    # export type EyesUFGConfig = {
    #   concurrentSessions?: number
    #   browsersInfo?: (DesktopBrowserRenderer | ChromeEmulationDeviceRenderer | IOSDeviceRenderer)[]
    #   visualGridOptions?: Record<string, any>
    #   layoutBreakpoints?: boolean | number[]
    #   disableBrowserFetching?: boolean
    # }
    json_fields :concurrentSessions,
      :browsersInfo,
      :visualGridOptions,
      :layoutBreakpoints,
      :disableBrowserFetching

    # v3
    json_fields :environment
    # :updateBaselineIfDifferent,
    # :updateBaselineIfNew,
    # :ignoreGitBranching,
    # :abortIdleTestTimeout

    # 23 + 3 + 2 + 11 = 39
    FROM_ORIGINAL_EYES = [:api_key, :app_name, :batch, :browsers_info, :concurrent_sessions, :debug_screenshots,
      :force_full_page_screenshot, :hide_caret, :hide_scrollbars, :host_app, :host_os, :match_timeout, :proxy,
      :save_failed_tests, :save_new_tests, :scale_ratio, :send_dom, :server_url, :stitch_mode, :test_name,
      :viewport_size, :visual_grid_options, :wait_before_screenshots, :wait_before_capture] + [
      :disabled?, # disabled? => is_disabled
      :stitching_overlap, # SeleniumEyes.stitching_overlap => stitch_overlap
      :dont_fetch_resources # dont_fetch_resources => disable_browser_fetching
    ] + [
      :layout_breakpoints,
      :scroll_root_element,
    ] + [
      :environment_name, :branch_name, :default_match_settings, :properties, :parent_branch_name,
      :compare_with_parent_branch, :baseline_env_name, :save_diffs, :session_type, :baseline_branch_name
    ]

    # 51 - 39 - 2 = 10
    OTHER = [:logs, :remove_session, :remote_events, :display_name, :host_app_info, :host_os_info, :device_info,
      :ignore_baseline, :cut, :rotation ]


    alias disabled= is_disabled=
    alias stitching_overlap= stitch_overlap=
    alias dont_fetch_resources= disable_browser_fetching=

    def initialize(*args)
      options = Applitools::Utils.extract_options! args
      options.keys.select {|k| options[k] && respond_to?("#{k}=") }.each {|k| send("#{k}=", options[k]) }
      # other
      self.connection_timeout = Applitools::Connectivity::ServerConnector::DEFAULT_TIMEOUT
      if 'true'.casecmp(ENV['APPLITOOLS_DONT_CLOSE_BATCHES'] || '') == 0
        self.dont_close_batches = true
        Applitools::EyesLogger.info('APPLITOOLS_DONT_CLOSE_BATCHES environment variable set to true. Doing nothing.')
      end
    end

    def from_eyes_images
      FROM_ORIGINAL_EYES - [
        :browsers_info,
        :concurrent_sessions,
        :debug_screenshots,
        :force_full_page_screenshot,
        :hide_caret,
        :hide_scrollbars,
        :send_dom,
        :stitch_mode,
        :visual_grid_options,
        :wait_before_screenshots,
        :wait_before_capture,
        :stitching_overlap
      ]

    end

    def from_original_sdk(original_eyes)
      from_eyes = original_eyes.class.name != 'Applitools::Images::Eyes' ? FROM_ORIGINAL_EYES : from_eyes_images
      from_eyes.each {|m| copy_from(m, original_eyes) }
      self.agent_id = original_eyes.base_agent_id if original_eyes.respond_to?(:base_agent_id)
      self.agent_id = original_eyes.full_agent_id if original_eyes.respond_to?(:full_agent_id)
      # self.display_name = original_eyes.app_name
      self.dont_close_batches = original_eyes.dont_close_batches unless original_eyes.dont_close_batches.nil?
      prepare_for_json!
    end

    def copy_from(what, from)
      if from.respond_to?(what)
        send("#{what.to_s.chomp('?') }=", from.send(what))
      else
        puts "respond_to? #{what} - fail"
      end
    end

    def prepare_for_json!
      self.batch = batch.to_hash if batch.is_a?(Applitools::BatchInfo)
      self.browsers_info = browsers_info.to_hash if browsers_info.is_a?(Applitools::Selenium::BrowsersInfo)
      self.default_match_settings = default_match_settings.to_hash if default_match_settings.is_a?(Applitools::ImageMatchSettings)
      self.proxy = proxy.to_hash if proxy.is_a?(Applitools::Connectivity::Proxy)
      self.viewport_size = viewport_size.to_h if viewport_size.is_a?(Applitools::RectangleSize)
      v3api_change
      # require 'pry'
      # binding.pry
    end

    def v3api_change
      # self.updateBaselineIfDifferent = saveFailedTests unless saveFailedTests.nil?
      # self.updateBaselineIfNew = saveNewTests unless saveNewTests.nil?
      environment = {}
      environment[:hostApp] = hostApp unless hostApp.nil?
      environment[:hostAppInfo] = hostAppInfo unless hostAppInfo.nil?
      environment[:hostOS] = hostOS unless hostOS.nil?
      environment[:hostOSInfo] = hostOSInfo unless hostOSInfo.nil?
      environment[:deviceInfo] = deviceInfo unless deviceInfo.nil?
      unless viewportSize.nil?
        environment[:viewportSize] = viewportSize
        self.viewportSize = nil
      end
      self.environment = environment unless environment.empty?
      # :ignoreGitBranching, :abortIdleTestTimeout
    end

    def to_hash
      json_data.compact.reject do |_, v|
        case v
          when Array, Hash
            v.empty?
          when Numeric
            v.zero?
          # when FalseClass
          #   true
          else
            false
        end
      end
    end

  end
end
# U-Notes : Added internal Applitools::UniversalEyesConfig
