RSpec.describe Applitools::EyesBaseConfiguration do
  context 'ignore_displacements' do
    it_should_behave_like 'responds to method', [:ignore_displacements, :ignore_displacements=]
    it 'default value' do
      expect(subject.default_match_settings.ignore_displacements).to be false
    end

    it 'passes value to image_match_settings' do
      subject.ignore_displacements = false
      expect(subject.default_match_settings.ignore_displacements).to be false
      subject.ignore_displacements = true
      expect(subject.default_match_settings.ignore_displacements).to be true
      subject.ignore_displacements = false
      expect(subject.default_match_settings.ignore_displacements).to be false
    end
  end

  context 'match_timeout' do
    it 'provides methods' do
      expect(subject).to respond_to(:match_timeout)
      expect(subject).to respond_to(:match_timeout=)
    end

    it 'default value' do
      expect(subject.match_timeout).to eq Applitools::EyesBaseConfiguration::DEFAULT_MATCH_TIMEOUT
    end

    it 'sets value' do
      subject.match_timeout = 5342
      expect(subject.match_timeout).to eq(5342)
      subject.match_timeout = 0
      expect(subject.match_timeout).to eq(0)
    end
  end
end