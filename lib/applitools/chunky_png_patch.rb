require 'oily_png'
# require 'chunky_png'
require_relative 'chunky_png/resampling'
require 'eyes_core/eyes_core'

ChunkyPNG::Canvas.class_eval do
  include Applitools::ChunkyPNG::Resampling
  include Applitools::ResamplingFast
end
