RSpec.describe 'Applitools::Selenium::Configuration' do
  let(:conf) { Applitools::Selenium::Configuration.new }
  context 'default values' do
    it 'ignore_caret' do
      expect(conf.ignore_caret).to be_truthy
    end
  end
  context 'set a value' do
    it 'ignore_caret' do
      conf.ignore_caret = false
      expect(conf.ignore_caret).to be_falsy
    end
  end
  context 'default value again' do
    it 'ignore_caret' do
      expect(conf.ignore_caret).to be_truthy
    end
  end
end