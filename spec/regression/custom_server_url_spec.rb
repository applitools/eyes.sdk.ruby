require 'rspec'
require 'spec_helper'

RSpec.describe 'Server URL double slash' do
  before do
    allow_any_instance_of(Faraday::Response).to receive(:status).and_return(200)
    allow_any_instance_of(Faraday::Response).to receive(:body).and_return('{}')
  end
  let(:ok_response) { Faraday::Response.new }
  subject { Applitools::Connectivity::ServerConnector.new('https://my.custom.url/') }
  it 'rendering_info' do
    expect(subject).to(
      receive(:long_get)
          .with(URI('https://my.custom.url/api/sessions/renderinfo'), any_args)
          .and_return(ok_response)
    )
    subject.rendering_info
  end
  it 'render' do
    expect(subject).to receive(:dummy_post).with(URI('http://my.service.url/render'), any_args).and_return(ok_response)
    subject.render('http://my.service.url', 'key', Applitools::Selenium::RenderRequests.new)
  end
end

