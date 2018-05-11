# frozen_string_literal: true

module Applitools::MatchLevelSetter
  def match_level_with_exact(value, exact_options = {})
    raise Applitools::EyesError unless Applitools::MATCH_LEVEL.keys.include? value
    if value != :exact && (exact_options && !exact_options.empty?)
      raise Applitools::EyesError.new(
        'Exact options are accepted only for EXACT match level'
      )
    end
    [Applitools::MATCH_LEVEL[value], value == :exact ? convert_exact_options(exact_options) : nil]
  end

  private

  EXACT_KEYS = {
    :min_diff_intensity => 'MinDiffIntensity',
    :min_diff_width => 'MinDiffWidth',
    :min_diff_height => 'MinDiffHeight',
    :match_threshold => 'MatchThreshold',
    'MinDiffIntensity' => 'MinDiffIntensity',
    'MinDiffWidth' => 'MinDiffWidth',
    'MinDiffHeight' => 'MinDiffHeight',
    'MatchThreshold' => 'MatchThreshold'
  }.freeze

  def convert_exact_options(options)
    allowed_keys = EXACT_KEYS.keys
    extra_keys = options.keys - allowed_keys
    result = {
      'MinDiffIntensity' => 0,
      'MinDiffWidth' => 0,
      'MinDiffHeight' => 0,
      'MatchThreshold' => 0
    }
    unless extra_keys.empty?
      raise Applitools::EyesIllegalArgument.new(
        "Extra exact keys passed - [#{extra_keys.join(', ')}]"
      )
    end

    allowed_keys.each do |k|
      result[EXACT_KEYS[k]] = options[k] unless options[k].nil?
    end
    result
  end
end
