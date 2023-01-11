# frozen_string_literal: true

require 'spec_helper'

$batch_info ||= Applitools::BatchInfo.new "Ruby new image tests"

RSpec.describe 'Eyes Images' do

  # let(:image_url_jpg) { 'https://applitools.github.io/demo/images/image_1.jpg' }
  # let(:image_url_jpeg) { 'https://applitools.github.io/demo/images/minions_jpeg.jpeg' }
  # let(:image_url_png) { 'https://applitools.github.io/upload/appium.png' }
  # let(:image_url_bmp) { 'https://applitools.github.io/demo/images/minions_bitmap.bmp' }
  # let(:image_path_jpeg) { './spec/images/resources/minions_jpeg.jpeg' }
  # let(:image_path_png) { './spec/images/resources/minions_png.png' }
  # let(:image_path_bmp) { './spec/images/resources/minions_bitmap.bmp' }

  let(:image_url_jpeg) { 'https://raw.githubusercontent.com/applitools/eyes.sdk.javascript1/master/python/tests/resources/jpg.jpg' }
  let(:image_url_png) { 'https://raw.githubusercontent.com/applitools/eyes.sdk.javascript1/master/python/tests/resources/png.png' }
  let(:image_url_bmp) { 'https://raw.githubusercontent.com/applitools/eyes.sdk.javascript1/master/python/tests/resources/bmp.bmp' }

  let(:image_path_jpeg) { './spec/images/resources/jpg.jpg' }
  let(:image_path_png) { './spec/images/resources/png.png' }
  let(:image_path_bmp) { './spec/images/resources/bmp.bmp' }

  let(:ocr_image) { './spec/images/resources/extractText.png' }


  let(:eyes) { Applitools::Images::Eyes.new }
  let(:app_name) { 'Eyes Images' }
  let(:viewport_size) { { width: 150, height: 150 } }

  around(:example) do |example|
    begin
      eyes.batch = $batch_info if $batch_info
      eyes.save_new_tests = false
      eyes.branch_name = 'default'
      # eyes.parent_branch_name = 'master'
      example.run
    ensure
      eyes.close(true) if eyes.open?
    end
  end



  context 'check_image' do
    it 'PNG path' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_image[path-png]')
      eyes.check_image(image_path: image_path_png)
    end

    it 'BitMap path' do
      eyes.open(app_name: app_name, viewport_size: viewport_size, test_name: 'test_image_check_image[path-bmp]')
      eyes.check_image(image_path: image_path_bmp)
    end

    it 'Path path' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_image[path-jpg]')
      eyes.check_image(image_path: image_path_jpeg)
    end

    it 'PNG url' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_image[url-png]')
      eyes.check_image(image_path: image_url_png)
    end

    it 'BitMap url' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_image[url-bmp]')
      eyes.check_image(image_path: image_url_bmp)
    end

    it 'JPEG url' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_image[url-jpg]')
      eyes.check_image(image_path: image_url_jpeg)
    end

    it 'PNG Buffer' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_image[buffer-png]')
      eyes.check_image(image: File.read(image_path_png, mode: 'rb'))
    end

    it 'BitMap Buffer' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_image[buffer-bmp]')
      eyes.check_image(image: File.read(image_path_bmp, mode: 'rb'))
    end

    it 'JPEG Buffer' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_image[buffer-jpg]')
      eyes.check_image(image: File.read(image_path_jpeg, mode: 'rb'))
    end
  end



  context 'check_region' do
    it 'PNG path' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_region[path-png]')
      eyes.check_region(image_path: image_path_png, region: Applitools::Region.new(50, 50, 50, 50))
    end

    it 'BitMap path' do
      eyes.open(app_name: app_name, viewport_size: viewport_size, test_name: 'test_image_check_region[path-bmp]')
      eyes.check_region(image_path: image_path_bmp, region: Applitools::Region.new(50, 50, 50, 50))
    end

    it 'Path path' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_region[path-jpg]')
      eyes.check_region(image_path: image_path_jpeg, region: Applitools::Region.new(50, 50, 50, 50))
    end

    it 'PNG url' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_region[url-png]')
      eyes.check_region(image_path: image_url_png, region: Applitools::Region.new(50, 50, 50, 50))
    end

    it 'BitMap url' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_region[url-bmp]')
      eyes.check_region(image_path: image_url_bmp, region: Applitools::Region.new(50, 50, 50, 50))
    end

    it 'JPEG url' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_region[url-jpg]')
      eyes.check_region(image_path: image_url_jpeg, region: Applitools::Region.new(50, 50, 50, 50))
    end

    it 'PNG Buffer' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_region[buffer-png]')
      eyes.check_region(image: File.read(image_path_png, mode: 'rb'), region: Applitools::Region.new(50, 50, 50, 50))
    end

    it 'BitMap Buffer' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_region[buffer-bmp]')
      eyes.check_region(image: File.read(image_path_bmp, mode: 'rb'), region: Applitools::Region.new(50, 50, 50, 50))
    end

    it 'JPEG Buffer' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_region[buffer-jpg]')
      eyes.check_region(image: File.read(image_path_jpeg, mode: 'rb'), region: Applitools::Region.new(50, 50, 50, 50))
    end
  end



  context 'check_fluent image' do
    it 'PNG path' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[image-path-png]')
      eyes.check('entire image', Applitools::Images::Target.any(image_path: image_path_png))
    end

    it 'BitMap path' do
      eyes.open(app_name: app_name, viewport_size: viewport_size, test_name: 'test_image_check_fluent[image-path-bmp]')
      eyes.check('entire image', Applitools::Images::Target.any(image_path: image_path_bmp))
    end

    it 'Path path' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[image-path-jpg]')
      eyes.check('entire image', Applitools::Images::Target.any(image_path: image_path_jpeg))
    end

    it 'PNG url' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[image-url-png]')
      eyes.check('entire image', Applitools::Images::Target.any(image_path: image_url_png))
    end

    it 'BitMap url' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[image-url-bmp]')
      eyes.check('entire image', Applitools::Images::Target.any(image_path: image_url_bmp))
    end

    it 'JPEG url' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[image-url-jpg]')
      eyes.check('entire image', Applitools::Images::Target.any(image_path: image_url_jpeg))
    end

    it 'PNG Buffer' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[image-buffer-png]')
      eyes.check('entire image', Applitools::Images::Target.any(image: File.read(image_path_png, mode: 'rb')))
    end

    it 'BitMap Buffer' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[image-buffer-bmp]')
      eyes.check('entire image', Applitools::Images::Target.any(image: File.read(image_path_bmp, mode: 'rb')))
    end

    it 'JPEG Buffer' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[image-buffer-jpg]')
      eyes.check('entire image', Applitools::Images::Target.any(image: File.read(image_path_jpeg, mode: 'rb')))
    end
  end



  context 'check_fluent region' do
    it 'PNG path' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[region-path-png]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).region(Applitools::Region.new(50, 50, 50, 50)))
    end

    it 'BitMap path' do
      eyes.open(app_name: app_name, viewport_size: viewport_size, test_name: 'test_image_check_fluent[region-path-bmp]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_bmp).region(Applitools::Region.new(50, 50, 50, 50)))
    end

    it 'Path path' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[region-path-jpg]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_jpeg).region(Applitools::Region.new(50, 50, 50, 50)))
    end

    it 'PNG url' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[region-url-png]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_url_png).region(Applitools::Region.new(50, 50, 50, 50)))
    end

    it 'BitMap url' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[region-url-bmp]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_url_bmp).region(Applitools::Region.new(50, 50, 50, 50)))
    end

    it 'JPEG url' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[region-url-jpg]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_url_jpeg).region(Applitools::Region.new(50, 50, 50, 50)))
    end

    it 'PNG Buffer' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[region-buffer-png]')
      eyes.check('image region', Applitools::Images::Target.any(image: File.read(image_path_png, mode: 'rb')).region(Applitools::Region.new(50, 50, 50, 50)))
    end

    it 'BitMap Buffer' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[region-buffer-bmp]')
      eyes.check('image region', Applitools::Images::Target.any(image: File.read(image_path_bmp, mode: 'rb')).region(Applitools::Region.new(50, 50, 50, 50)))
    end

    it 'JPEG Buffer' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent[region-buffer-jpg]')
      eyes.check('image region', Applitools::Images::Target.any(image: File.read(image_path_jpeg, mode: 'rb')).region(Applitools::Region.new(50, 50, 50, 50)))
    end
  end



  context 'check_fluent' do
    it 'ignore image' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_ignore[image]')
      eyes.check('image ignore',
                 Applitools::Images::Target.any(image: File.read(image_path_png, mode: 'rb')).
                   ignore(Applitools::Region.new(0, 0, 25, 25)))
    end

    it 'ignore region' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_ignore[region]')
      eyes.check('image region with ignore',
                 Applitools::Images::Target.any(image: File.read(image_path_png, mode: 'rb')).
                   region(Applitools::Region.new(50, 50, 50, 50)).
                   ignore(Applitools::Region.new(0, 0, 25, 25)))
    end

    it 'floating image' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_floating[image]')
      eyes.check('image ignore',
                 Applitools::Images::Target.any(image: File.read(image_path_png, mode: 'rb')).
                   floating(
                     Applitools::FloatingBounds.new(0, 0, 25, 25),
                     Applitools::PaddingBounds.new(1, 2, 3, 4)))
    end

    it 'floating region' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_floating[region]')
      eyes.check('image region with ignore',
                 Applitools::Images::Target.any(image: File.read(image_path_png, mode: 'rb')).
                   region(Applitools::Region.new(50, 50, 50, 50)).
                   floating(
                     Applitools::FloatingBounds.new(0, 0, 25, 25),
                     Applitools::PaddingBounds.new(1, 2, 3, 4)))
    end

    it 'ignore_displacements image true' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_ignore_displacements[image-True]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).ignore_displacements(true))
    end

    it 'ignore_displacements image false' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_ignore_displacements[image-False]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).ignore_displacements(false))
    end

    it 'ignore_displacements region true' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_ignore_displacements[region-True]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).
        region(Applitools::Region.new(50, 50, 50, 50)).ignore_displacements(true))
    end

    it 'ignore_displacements region false' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_ignore_displacements[region-False]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).
        region(Applitools::Region.new(50, 50, 50, 50)).ignore_displacements(false))
    end

    it 'enable_patterns image true' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_ignore_displacements[image-True]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).enable_patterns(true))
    end

    it 'enable_patterns image false' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_ignore_displacements[image-False]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).enable_patterns(false))
    end

    it 'enable_patterns region true' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_ignore_displacements[region-True]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).
        region(Applitools::Region.new(50, 50, 50, 50)).enable_patterns(true))
    end

    it 'enable_patterns region false' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_ignore_displacements[region-False]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).
        region(Applitools::Region.new(50, 50, 50, 50)).enable_patterns(false))
    end
  end

  context 'check_fluent match_level' do
    it 'image NONE' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[image-MatchLevel.NONE]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).match_level(Applitools::MatchLevel::NONE))
    end

    it 'image LAYOUT' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[image-MatchLevel.LAYOUT]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).match_level(Applitools::MatchLevel::LAYOUT))
    end

    it 'image LAYOUT1' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[image-MatchLevel.LAYOUT1]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).match_level(Applitools::MatchLevel::LAYOUT1))
    end

    it 'image LAYOUT2' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[image-MatchLevel.LAYOUT2]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).match_level(Applitools::MatchLevel::LAYOUT2))
    end

    xit 'image CONTENT' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[image-MatchLevel.CONTENT]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).match_level(Applitools::MatchLevel::CONTENT))
    end

    it 'image IGNORE_COLORS' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[image-MatchLevel.IGNORE_COLORS]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).match_level(Applitools::MatchLevel::IGNORE_COLORS))
    end

    it 'image STRICT' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[image-MatchLevel.STRICT]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).match_level(Applitools::MatchLevel::STRICT))
    end

    it 'image EXACT' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[image-MatchLevel.EXACT]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).match_level(Applitools::MatchLevel::EXACT))
    end
  end

  context 'check_fluent match_level' do
    it 'region NONE' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[region-MatchLevel.NONE]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).
        region(Applitools::Region.new(50, 50, 50, 50)).match_level(Applitools::MatchLevel::NONE))
    end

    it 'region LAYOUT' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[region-MatchLevel.LAYOUT]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).
        region(Applitools::Region.new(50, 50, 50, 50)).match_level(Applitools::MatchLevel::LAYOUT))
    end

    it 'region LAYOUT1' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[region-MatchLevel.LAYOUT1]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).
        region(Applitools::Region.new(50, 50, 50, 50)).match_level(Applitools::MatchLevel::LAYOUT1))
    end

    it 'region LAYOUT2' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[region-MatchLevel.LAYOUT2]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).
        region(Applitools::Region.new(50, 50, 50, 50)).match_level(Applitools::MatchLevel::LAYOUT2))
    end

    xit 'region CONTENT' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[region-MatchLevel.CONTENT]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).
        region(Applitools::Region.new(50, 50, 50, 50)).match_level(Applitools::MatchLevel::CONTENT))
    end

    it 'region IGNORE_COLORS' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[region-MatchLevel.IGNORE_COLORS]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).
        region(Applitools::Region.new(50, 50, 50, 50)).match_level(Applitools::MatchLevel::IGNORE_COLORS))
    end

    it 'region STRICT' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[region-MatchLevel.STRICT]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).
        region(Applitools::Region.new(50, 50, 50, 50)).match_level(Applitools::MatchLevel::STRICT))
    end

    it 'region EXACT' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_check_fluent_match_level[region-MatchLevel.EXACT]')
      eyes.check('image region', Applitools::Images::Target.any(image_path: image_path_png).
        region(Applitools::Region.new(50, 50, 50, 50)).match_level(Applitools::MatchLevel::EXACT))
    end
  end

  context 'extract_text' do
    it 'image' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_extract_text')
      texts = eyes.extract_text(image: ocr_image)
      expect(texts[0]).to eql('This is the navigation bar')
    end

    it 'with region' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'test_image_extract_text_region')
      texts = eyes.extract_text({image: ocr_image}, [{ 'target' => { 'left' => 55, 'top' => 11, 'width' => 214, 'height' => 18 } }])
      expect(texts[0]).to eql('s the navigation bar')
    end

    it 'extract_text_regions' do
      eyes.open(app_name: app_name, viewport_size: viewport_size,  test_name: 'TestExtractTextRegions')
      regions = eyes.extract_text_regions({ 'patterns' => [".+"], 'image' => ocr_image })
      expect(regions[".+"]).to eql([{"x"=>10, "y"=>11, "width"=>214, "height"=>18, "text"=>"Thisisthenavigationbar"}])
    end
  end

  # context 'Old style' do
  #   xit 'Applitools::Screenshot' do
  #
  #   end
  #
  #   xit 'ChunkyPNG::Image' do
  #
  #   end
  # end

end
