RSpec.shared_examples 'BrowserType' do |const, value|
  it 'Returns symbol' do
    expect(subject.const_get(const)).to be_a(Symbol)
  end

  it "#{const} returns #{value}" do
    expect(subject.const_get(const).to_s).to eq(value)
  end
end
RSpec.describe BrowserTypes do
  it_should_behave_like 'BrowserType', 'CHROME', 'chrome-0'
  it_should_behave_like 'BrowserType', 'CHROME_ONE_VERSION_BACK', 'chrome-1'
  it_should_behave_like 'BrowserType', 'CHROME_TWO_VERSIONS_BACK', 'chrome-2'

  it_should_behave_like 'BrowserType', 'FIREFOX', 'firefox-0'
  it_should_behave_like 'BrowserType', 'FIREFOX_ONE_VERSION_BACK', 'firefox-1'
  it_should_behave_like 'BrowserType', 'FIREFOX_TWO_VERSIONS_BACK', 'firefox-2'

  it_should_behave_like 'BrowserType', 'SAFARI', 'safari-0'
  it_should_behave_like 'BrowserType', 'SAFARI_ONE_VERSION_BACK', 'safari-1'
  it_should_behave_like 'BrowserType', 'SAFARI_TWO_VERSIONS_BACK', 'safari-2'

  it_should_behave_like 'BrowserType', 'IE_11', 'ie'
  it_should_behave_like 'BrowserType', 'IE_10', 'ie10'
  it_should_behave_like 'BrowserType', 'EDGE', 'edge'
end