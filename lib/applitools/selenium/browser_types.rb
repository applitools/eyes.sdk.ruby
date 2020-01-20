# frozen_string_literal: true
module BrowserTypes
  extend self
  CHROME = :'chrome-0'
  CHROME_ONE_VERSION_BACK = :'chrome-1'
  CHROME_TWO_VERSIONS_BACK = :'chrome-2'

  FIREFOX = :'firefox-0'
  FIREFOX_ONE_VERSION_BACK = :'firefox-1'
  FIREFOX_TWO_VERSIONS_BACK = :'firefox-2'

  SAFARI = :'safari-0'
  SAFARI_ONE_VERSION_BACK = :'safari-1'
  SAFARI_TWO_VERSIONS_BACK = :'safari-2'

  IE_11 = :ie
  EDGE = :edge
  IE_10 = :ie10

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
      EDGE,
      IE_10
    ]
  end
end
