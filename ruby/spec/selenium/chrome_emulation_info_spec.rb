RSpec.describe 'Applitools::Selenium::ChromeEmulationInfo' do
  it 'can\'t be created with empty arguments' do
    expect { Applitools::Selenium::ChromeEmulationInfo.new }.to raise_error Applitools::EyesIllegalArgument
  end
  context 'can be created' do
    context 'by position argument' do
      it 'constructor' do
        expect do
          @info = Applitools::Selenium::ChromeEmulationInfo.new(
            Devices::IPhone5SE,
            Orientation::PORTRAIT,
            baseline_env_name: 'proba'
          )
        end.to_not raise_error
        expect(@info.baseline_env_name).to eq 'proba'
      end
    end
    context 'by hash (named arguments)' do
      it 'constructor' do
        expect do
          @info = Applitools::Selenium::ChromeEmulationInfo.new(
            device_name: Devices::IPhone678,
            orientation: Orientation::PORTRAIT,
            baseline_env_name: 'proba'
          )
        end.to_not raise_error
        expect(@info.baseline_env_name).to eq 'proba'
      end
    end
  end
end