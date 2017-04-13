require 'oily_png'
require_relative 'chunky_png_patch/resampling'
require 'eyes_core/eyes_core'

ChunkyPNG::Canvas.class_eval do
  include Applitools::ChunkyPNGPatch::Resampling
  include Applitools::ResamplingFast
end
