# frozen_string_literal: true

module Applitools
  class UniversalEyesManagerConfig

    def self.classic
      new(type: CLASSIC)
    end

    def self.vg(concurrent_open_sessions=1)
      new(type: VG, concurrency: concurrent_open_sessions, legacy: false)
    end

    # export type EyesManagerConfig<TType extends 'vg' | 'classic' = 'vg' | 'classic'> = {
    #   type: TType
    #   concurrency?: TType extends 'vg' ? number : never
    #   legacy?: TType extends 'vg' ? boolean : never
    # }
    attr_reader :type, :concurrency, :legacy

    VG = 'ufg'.freeze
    CLASSIC = 'classic'.freeze
    def type_enum_values
      [VG, CLASSIC]
    end

    def initialize(*args)
      options = Applitools::Utils.extract_options!(args)
      self.type = options[:type].to_s
      self.concurrency = options[:concurrency]
      self.legacy = options[:legacy]
    end

    # enum_field :type, Applitools::UniversalEyesManagerConfig.type_enum_values
    def type=(value)
      available_values_array = type_enum_values
      unless available_values_array.include? value
        msg = "Unknown type #{value}. Allowed type values: #{available_values_array.join(', ')}"
        raise(Applitools::EyesIllegalArgument, msg)
      end
      @type = value
    end

    def concurrency=(value)
      @concurrency = value.to_i if type == VG
    end

    def legacy=(value)
      @legacy = !!value if type == VG
    end

    def to_hash
      result = {}
      result[:type] = type
      result[:concurrency] = concurrency if concurrency
      result[:legacy] = legacy if legacy
      result.compact
    end

  end
end
# U-Notes : Added internal Applitools::UniversalEyesManagerConfig
