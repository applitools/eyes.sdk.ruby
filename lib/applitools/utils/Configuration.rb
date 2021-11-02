# frozen_string_literal: true

module Applitools::Utils
  class Configuration

    # EyesManagerConfig
    attr_accessor :type,
      :concurrency,
      :legacy

    # EyesBaseConfig
    attr_accessor :logs,
      :debugScreenshots,
      :agentId,
      :apiKey,
      :serverUrl,
      :proxy,
      :isDisabled,
      :connectionTimeout,
      :removeSession,
      :remoteEvents

    # EyesOpenConfig
    attr_accessor :appName,
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

    # EyesCheckConfig
    attr_accessor :sendDom,
      :matchTimeout,
      :forceFullPageScreenshot

    # EyesClassicConfig
    attr_accessor :waitBeforeScreenshots,
      :stitchMode,
      :hideScrollbars,
      :hideCaret,
      :stitchOverlap,
      :scrollRootElement,
      :cut,
      :rotation,
      :scaleRatio

    # EyesUFGConfig
    attr_accessor :concurrentSessions,
      :browsersInfo,
      :visualGridOptions,
      :layoutBreakpoints,
      :disableBrowserFetching

    def method_missing(m, *args, &block)
      key = key_convert m
      if respond_to?(key)
        self.send(key.to_sym, *args, &block)
      else
        puts "There's no method called #{m} here -- please try again."
        binding.pry
      end
    end

    attr_accessor :vg

    def batch_info= v
      @batch = v
    end

    def batch
      if !@batch
        @batch = {
          id: ENV['APPLITOOLS_BATCH_ID'],
          name: ENV['APPLITOOLS_BATCH_NAME'],
          sequenceName: ENV['APPLITOOLS_BATCH_SEQUENCE'],
          notifyOnCompletion: !!ENV['APPLITOOLS_BATCH_NOTIFY'],
        }
      else
        @batch[:id] = ENV['APPLITOOLS_BATCH_ID'] if @batch[:id].nil? && ENV['APPLITOOLS_BATCH_ID']
        @batch
      end
    end

    def to_socket_output
      keys = (self.public_methods(false) - [:method_missing, :key_convert, :batch_info=, :to_socket_output, :to_h]).
        reject {|m| m.to_s.include?('=')}
      values = keys.sort.each_with_object({}) do |k, h|
        v = self.public_send(k)
        v = v.to_socket_output if v.respond_to?(:to_socket_output)
        h[k] = v
      end
      values.compact!
      # binding.pry
      values
    end

    def to_h
      to_socket_output
    end

    def disabled=(toggle = true)
      self.isDisabled = !!toggle
    end

    private

    def key_convert name
      return name unless name.to_s.include?('_')
      key = name.to_s.split('_').map(&:capitalize).join
      key[0] = key[0].downcase
      key
    end

    def type
      vg ? 'vg' : 'classic'
    end

    def concurrency
      vg ? @concurrency : 0
    end

    def legacy
      vg ? @legacy : 0
    end

  end
end
