# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'vg_resource', skip: true do
  let(:content) { |example| File.read(example.description) }

  it 'spec/fixtures/applitools_logo_combined.svg' do
    block = proc do |list, url|
      expect(url).to be_a(URI)
      expect(url.to_s).to eq('https://applitools.com')
      expect(list).to include('logo.svg')
      expect(list).to include('company_name.png')
      expect(list).to include('slogan.svg')
    end

    Applitools::Selenium::VGResource.new(
      'https://applitools.com',
      'image/svg+xml',
      content,
      on_resources_fetched: block
    )
  end

  it 'spec/fixtures/chevron.svg' do
    block = proc do |l, u|
      expect(l).to be_a(Array)
      expect(u).to be_a(URI)
      expect(u.to_s).to eq('https://applitools.com')
    end
    expect do
      Applitools::Selenium::VGResource.new(
        'https://applitools.com',
        'image/svg+xml',
        content,
        on_resources_fetched: block
      )
    end.to_not raise_error
  end

  it 'spec/fixtures/carat-u-blue.svg' do
    block = proc do |l, u|
      expect(l).to be_a(Array)
      expect(u).to be_a(URI)
      expect(l).to_not include('#path-1')
    end
    expect do
      Applitools::Selenium::VGResource.new(
        'https://applitools.com',
        'image/svg+xml',
        content,
        on_resources_fetched: block
      )
    end.to_not raise_error
  end

  it 'spec/fixtures/fa-regular-400.svg' do
    block = proc do |l, u|
      expect(l).to be_a(Array)
      expect(u).to be_a(URI)
      expect(u.to_s).to eq('https://applitools.com')
    end
    expect do
      Applitools::Selenium::VGResource.new(
        'https://applitools.com',
        'image/svg+xml',
        content,
        on_resources_fetched: block
      )
    end.to_not raise_error
  end

  it 'spec/fixtures/font-awesome.min.css' do
    block = proc do |l, u|
      expect(l).to be_a(Array)
      expect(l).to include('../fonts/fontawesome-webfont.woff2?v=4.7.0')
      expect(l).to include('../fonts/fontawesome-webfont.woff?v=4.7.0')
      expect(l).to include('../fonts/fontawesome-webfont.ttf?v=4.7.0')
      expect(u).to be_a(URI)
      expect(u.to_s).to eq('https://applitools.com')
    end
    expect do
      Applitools::Selenium::VGResource.new(
        'https://applitools.com',
        'text/css',
        content,
        on_resources_fetched: block
      )
    end.to_not raise_error
  end

  context 'Read from blob' do
    context 'Error resource' do
      let(:good_blob) { {'url' => 'https://google.com', 'type' => 'text/html', 'value' => 'VGVzdCBjb250ZW50'} }
      let(:error_blob) { {'url' => 'https://google.com', 'type' => nil, 'value' => '', 'errorStatusCode' => 403} }
      it 'common' do
        resource = Applitools::Selenium::VGResource.parse_blob_from_script(good_blob)
        expect(resource.json_data.keys).to_not include('errorStatusCode'.to_sym)
      end

      it 'with error' do
        resource = Applitools::Selenium::VGResource.parse_blob_from_script(error_blob)
        expect(resource.json_data.keys).to include('errorStatusCode'.to_sym)
      end
    end
  end
end
