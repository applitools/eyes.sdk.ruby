# frozen_string_literal: true
module BrowserTypes
  extend self
  CHROME = :chrome
  FIREFOX = :firefox
  IE_11 = :ie
  EDGE = :edge
  IE_10 = :ie10

  def enum_values
    [CHROME, FIREFOX, IE_11, EDGE, IE_10]
  end
end
