# frozen_string_literal: true
module BrowserTypes
  extend self
  def const_missing(name)
    puts 'Please, prefer using BrowserType instead of BrowserTypes(plural).'
    BrowserType.const_get(name)
  end

  def enum_values
    BrowserType.enum_values
  end
end
module BrowserType
  extend self
  CHROME = :'chrome'
  CHROME_ONE_VERSION_BACK = :'chrome-one-version-back'
  CHROME_TWO_VERSIONS_BACK = :'chrome-two-versions-back'

  FIREFOX = :'firefox'
  FIREFOX_ONE_VERSION_BACK = :'firefox-one-version-back'
  FIREFOX_TWO_VERSIONS_BACK = :'firefox-two-versions-back'

  SAFARI = :'safari'
  SAFARI_ONE_VERSION_BACK = :'safari-one-version-back'
  SAFARI_TWO_VERSIONS_BACK = :'safari-two-versions-back'
  IOS_SAFARI = :safari

  EDGE_CHROMIUM = :'edgechromium'
  EDGE_CHROMIUM_ONE_VERSION_BACK = :'edgechromium-one-version-back'
  EDGE_CHROMIUM_TWO_VERSIONS_BACK = :'edgechromium-two-versions-back'

  IE_11 = :ie
  EDGE_LEGACY = :edgelegacy
  IE_10 = :ie10

  def const_defined?(name)
    return true if name == :EDGE
    super
  end

  def const_missing(name)
    if name == :EDGE
      Applitools::EyesLogger.warn(
        'The \'EDGE\' option that is being used in your browsers\' configuration will soon be deprecated. ' \
        'Please change it to either \'EDGE_LEGACY\' for the legacy version ' \
        'or to \'EDGE_CHROMIUM\' for the new Chromium-based version.'
      )
      return EDGE_LEGACY
    end
    super
  end

  def enum_values
    [
      CHROME,
      CHROME_ONE_VERSION_BACK,
      CHROME_TWO_VERSIONS_BACK,
      FIREFOX,
      FIREFOX_ONE_VERSION_BACK,
      FIREFOX_TWO_VERSIONS_BACK,
      SAFARI,
      SAFARI_ONE_VERSION_BACK,
      SAFARI_TWO_VERSIONS_BACK,
      IE_11,
      EDGE_LEGACY,
      IE_10,
      EDGE_CHROMIUM,
      EDGE_CHROMIUM_ONE_VERSION_BACK,
      EDGE_CHROMIUM_TWO_VERSIONS_BACK,
      IOS_SAFARI
    ]
  end
end
